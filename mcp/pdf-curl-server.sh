#!/bin/sh
# MCP stdio server for PDF curl downloads
# POSIX sh, auto-detects jq or python3 for JSON parsing

set -e

# ---- JSON parser detection ----
JSON_TOOL=""
if command -v jq >/dev/null 2>&1; then
    JSON_TOOL="jq"
elif command -v python3 >/dev/null 2>&1; then
    JSON_TOOL="python3"
else
    echo '{"jsonrpc":"2.0","id":null,"error":{"code":-32603,"message":"No JSON parser available"}}' >&2
    exit 1
fi

# ---- JSON helpers ----
_json_get() {
    _key="$1"
    _json="$2"
    if [ "$JSON_TOOL" = "jq" ]; then
        printf '%s' "$_json" | jq -r --arg k "$_key" '.[$k] // empty'
    else
        printf '%s' "$_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('$_key','') if isinstance(d,dict) else '')"
    fi
}

_json_get_nested() {
    _path="$1"
    _json="$2"
    if [ "$JSON_TOOL" = "jq" ]; then
        printf '%s' "$_json" | jq -r --arg p "$_path" 'reduce ($p | split("."))[] as $k (.; .[$k]) // empty'
    else
        printf '%s' "$_json" | python3 -c "import sys,json; d=json.load(sys.stdin); v=d; [v:=v.get(k) if isinstance(v,dict) else None for k in '$_path'.split('.')]; print(v if v is not None else '')"
    fi
}

# ---- Response helpers ----
send_result() {
    _id="$1"
    _result="$2"
    printf '%s\n' "{\"jsonrpc\":\"2.0\",\"id\":$_id,\"result\":$_result}"
}

send_error() {
    _id="$1"
    _code="$2"
    _message="$3"
    printf '%s\n' "{\"jsonrpc\":\"2.0\",\"id\":$_id,\"error\":{\"code\":$_code,\"message\":\"$_message\"}}"
}

# ---- Tool: curl_download ----
validate_url() {
    case "$1" in
        https://*.pdf|http://*.pdf) return 0 ;;
        *) return 1 ;;
    esac
}

is_pdf_content_type() {
    case "$1" in
        application/pdf|application/x-pdf|application/octet-stream) return 0 ;;
        *) return 1 ;;
    esac
}

handle_curl_download() {
    _url="$1"
    _id="$2"

    if ! validate_url "$_url"; then
        send_error "$_id" -32602 "Invalid URL: must be http(s)://*.pdf"
        return
    fi

    _content_type=$(curl -s -o /dev/null -L --max-time 10 -w '%{content_type}' "$_url")
    if ! is_pdf_content_type "$_content_type"; then
        send_error "$_id" -32602 "Invalid Content-Type: $_content_type (expected application/pdf, application/x-pdf, or application/octet-stream)"
        return
    fi

    _basename=$(basename "$_url" | sed 's/[^a-zA-Z0-9._-]/_/g')
    _timestamp=$(date +%s)
    _output_path=".memory/pdf-${_timestamp}-${_basename}"

    mkdir -p .memory

    if ! curl -sfL --max-time 30 -o "$_output_path" "$_url" 2>/dev/null; then
        send_error "$_id" -32602 "Download failed for $_url"
        return
    fi

    _result="{\"content\":[{\"type\":\"text\",\"text\":\"Downloaded PDF to $_output_path (Content-Type: $_content_type)\"}],\"isError\":false}"
    send_result "$_id" "$_result"
}

# ---- Handlers ----
handle_initialize() {
    _id="$1"
    _result='{"protocolVersion":"2025-03-26","capabilities":{"experimental":{},"prompts":{"listChanged":false},"resources":{"subscribe":false,"listChanged":false},"tools":{"listChanged":false}},"serverInfo":{"name":"curl-download-server","version":"1.0.0"}}'
    send_result "$_id" "$_result"
}

handle_initialized() {
    # notification, no response
    :
}

handle_ping() {
    _id="$1"
    _result='{}'
    send_result "$_id" "$_result"
}

handle_tools_list() {
    _id="$1"
    _result='{"tools":[{"name":"curl_download","description":"Download a PDF from a URL after validating the URL and Content-Type","inputSchema":{"type":"object","properties":{"url":{"type":"string","description":"URL of the PDF to download (must end with .pdf)"}},"required":["url"]}}]}'
    send_result "$_id" "$_result"
}

handle_tools_call() {
    _id="$1"
    _params="$2"

    _name="$(_json_get_nested 'params.name' "$_params")"
    if [ -z "$_name" ]; then
        _name="$(_json_get 'name' "$_params")"
    fi

    if [ "$JSON_TOOL" = "jq" ]; then
        _url="$(printf '%s' "$_params" | jq -r '.params.arguments.url // .arguments.url // empty')"
    else
        _url="$(printf '%s' "$_params" | python3 -c "import sys,json; d=json.load(sys.stdin); a=d.get('params',{}).get('arguments',{}) if isinstance(d.get('params'),dict) else d.get('arguments',{}); print(a.get('url',''))")"
    fi

    if [ "$_name" != "curl_download" ]; then
        send_error "$_id" -32602 "Unknown tool: $_name"
        return
    fi

    if [ -z "$_url" ]; then
        send_error "$_id" -32602 "Missing required argument: url"
        return
    fi

    handle_curl_download "$_url" "$_id"
}

# ---- Main loop ----
while IFS= read -r line; do
    [ -z "$line" ] && continue

    _method="$(_json_get 'method' "$line")"
    _id_raw="$(_json_get 'id' "$line")"
    _id="$_id_raw"
    if [ -z "$_id" ]; then
        _id="null"
    fi

    case "$_method" in
        initialize)
            handle_initialize "$_id"
            ;;
        notifications/initialized)
            handle_initialized
            ;;
        ping)
            handle_ping "$_id"
            ;;
        tools/list)
            handle_tools_list "$_id"
            ;;
        tools/call)
            handle_tools_call "$_id" "$line"
            ;;
        *)
            if [ "$_id" != "null" ]; then
                send_error "$_id" -32601 "Method not found: $_method"
            fi
            ;;
    esac
done
