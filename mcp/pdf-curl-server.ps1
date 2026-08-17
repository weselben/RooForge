#!/usr/bin/env pwsh
# MCP stdio server for PDF curl downloads (PowerShell port)
# Uses native ConvertFrom-Json for JSON parsing (no jq/python3 needed)
# Compatible with Windows PowerShell 5.1 and PowerShell 7+

# ---- UTF-8 stdio setup (no BOM, LF line endings) ----
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$reader = New-Object System.IO.StreamReader([Console]::OpenStandardInput(), $utf8NoBom)
$writer = New-Object System.IO.StreamWriter([Console]::OpenStandardOutput(), $utf8NoBom)
$writer.AutoFlush = $true
$writer.NewLine = "`n"

# ---- Response helpers ----
function Send-Result {
    param([string]$Id, [string]$Result)
    $writer.WriteLine("{`"jsonrpc`":`"2.0`",`"id`":$Id,`"result`":$Result}")
}

function Send-Error {
    param([string]$Id, [int]$Code, [string]$Message)
    # Defensive: escape any embedded double quotes in the message
    $safeMessage = $Message -replace '\\', '\\' -replace '"', '\\"'
    $writer.WriteLine("{`"jsonrpc`":`"2.0`",`"id`":$Id,`"error`":{`"code`":$Code,`"message`":`"$safeMessage`"}}")
}

# ---- Validation helpers ----
function Test-ValidUrl {
    param([string]$Url)
    return ($Url -match '^https?://.+\.pdf$')
}

function Test-PdfContentType {
    param([string]$ContentType)
    if ([string]::IsNullOrEmpty($ContentType)) { return $false }
    $ct = ($ContentType -split ';')[0].Trim().ToLower()
    return $ct -in @('application/pdf', 'application/x-pdf', 'application/octet-stream')
}

# ---- Content-Type detection (HEAD request with fallback) ----
function Get-UrlContentType {
    param([string]$Url)

    # Try Invoke-WebRequest HEAD first
    try {
        $response = Invoke-WebRequest -Uri $Url -Method Head `
            -MaximumRedirection 10 -TimeoutSec 10 `
            -ErrorAction Stop -UseBasicParsing
        $ct = $null
        if ($response.Headers) {
            $raw = $response.Headers['Content-Type']
            if ($raw -is [System.Array]) { $ct = $raw[0] } else { $ct = $raw }
        }
        if (-not $ct -and $response.BaseResponse) {
            $ct = $response.BaseResponse.ContentType
        }
        if ($ct) { return $ct }
    } catch { }

    # Fallback: HttpWebRequest HEAD
    try {
        $request = [System.Net.HttpWebRequest]::Create($Url)
        $request.Method = "HEAD"
        $request.Timeout = 10000
        $request.AllowAutoRedirect = $true
        $request.UserAgent = "Mozilla/5.0 (compatible; curl-download-server)"
        $httpResponse = $request.GetResponse()
        $ct = $httpResponse.ContentType
        $httpResponse.Close()
        return $ct
    } catch { }

    return $null
}

# ---- Tool: curl_download ----
function Handle-CurlDownload {
    param([string]$Url, [string]$Id)

    if (-not (Test-ValidUrl $Url)) {
        Send-Error $Id -32602 "Invalid URL: must be http(s)://*.pdf"
        return
    }

    $contentType = Get-UrlContentType $Url
    if (-not (Test-PdfContentType $contentType)) {
        Send-Error $Id -32602 "Invalid Content-Type: $contentType (expected application/pdf, application/x-pdf, or application/octet-stream)"
        return
    }

    # Sanitize basename and build output path (matches shell behavior)
    $basename = [System.IO.Path]::GetFileName($Url) -replace '[^a-zA-Z0-9._-]', '_'
    $timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $outputDir = if ($env:PDF_CURL_OUTPUT_DIR) { $env:PDF_CURL_OUTPUT_DIR } else { '.' }
    $outputPath = Join-Path $outputDir "pdf-$timestamp-$basename"

    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

    try {
        Invoke-WebRequest -Uri $Url -OutFile $outputPath `
            -MaximumRedirection 10 -TimeoutSec 30 `
            -ErrorAction Stop -UseBasicParsing
    } catch {
        Send-Error $Id -32602 "Download failed for $Url"
        return
    }

    $result = "{`"content`":[{`"type`":`"text`",`"text`":`"Downloaded PDF to $outputPath (Content-Type: $contentType)`"}],`"isError`":false}"
    Send-Result $Id $result
}

# ---- MCP method handlers ----
function Handle-Initialize {
    param([string]$Id)
    $result = '{"protocolVersion":"2025-03-26","capabilities":{"experimental":{},"prompts":{"listChanged":false},"resources":{"subscribe":false,"listChanged":false},"tools":{"listChanged":false}},"serverInfo":{"name":"curl-download-server","version":"1.0.0"}}'
    Send-Result $Id $result
}

function Handle-Initialized {
    # notification, no response
}

function Handle-Ping {
    param([string]$Id)
    Send-Result $Id '{}'
}

function Handle-ToolsList {
    param([string]$Id)
    $result = '{"tools":[{"name":"curl_download","description":"Download a PDF from a URL after validating the URL and Content-Type","inputSchema":{"type":"object","properties":{"url":{"type":"string","description":"URL of the PDF to download (must end with .pdf)"}},"required":["url"]}}]}'
    Send-Result $Id $result
}

function Handle-ToolsCall {
    param([string]$Id, [string]$Params)

    $paramsObj = $null
    try {
        $paramsObj = $Params | ConvertFrom-Json -ErrorAction Stop
    } catch {
        Send-Error $Id -32602 "Invalid JSON in tools/call request"
        return
    }

    # Resolve tool name (params.name || name)
    $name = $null
    if ($paramsObj.PSObject.Properties.Name -contains 'params' -and
        $paramsObj.params.PSObject.Properties.Name -contains 'name') {
        $name = $paramsObj.params.name
    }
    if ($null -eq $name -and $paramsObj.PSObject.Properties.Name -contains 'name') {
        $name = $paramsObj.name
    }

    # Resolve url (params.arguments.url || arguments.url)
    $url = $null
    if ($paramsObj.PSObject.Properties.Name -contains 'params' -and
        $paramsObj.params.PSObject.Properties.Name -contains 'arguments') {
        $url = $paramsObj.params.arguments.url
    }
    if ($null -eq $url -and $paramsObj.PSObject.Properties.Name -contains 'arguments') {
        $url = $paramsObj.arguments.url
    }

    if ($name -ne 'curl_download') {
        Send-Error $Id -32602 "Unknown tool: $name"
        return
    }

    if ([string]::IsNullOrEmpty("$url")) {
        Send-Error $Id -32602 "Missing required argument: url"
        return
    }

    Handle-CurlDownload -Url "$url" -Id $Id
}

# ---- Main loop ----
while ($true) {
    $line = $reader.ReadLine()
    if ($null -eq $line) { break }       # EOF
    if ([string]::IsNullOrWhiteSpace($line)) { continue }

    $obj = $null
    try {
        $obj = $line | ConvertFrom-Json -ErrorAction Stop
    } catch {
        continue   # skip malformed input, like the shell version does implicitly
    }

    $method = $obj.method

    # Match shell behavior: missing/null id becomes the literal string "null"
    if ($obj.PSObject.Properties.Name -contains 'id' -and $null -ne $obj.id) {
        $id = "$($obj.id)"
    } else {
        $id = "null"
    }

    switch ($method) {
        'initialize'              { Handle-Initialize -Id $id }
        'notifications/initialized' { Handle-Initialized }
        'ping'                    { Handle-Ping -Id $id }
        'tools/list'              { Handle-ToolsList -Id $id }
        'tools/call'              { Handle-ToolsCall -Id $id -Params $line }
        default {
            if ($id -ne "null") {
                Send-Error $id -32601 "Method not found: $method"
            }
        }
    }
}