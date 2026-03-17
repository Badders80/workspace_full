#!/usr/bin/env bash
set -euo pipefail

MODEL="${ANTHROPIC_AUDIT_MODEL:-claude-sonnet-4-20250514}"
BASE_URL="${ANTHROPIC_BASE_URL:-https://api.anthropic.com/v1}"
API_KEY="${ANTHROPIC_API_KEY:-}"
PROMPT="${AUDIT_PROMPT:-${1:-}}"
HTTP_TIMEOUT_SECONDS="${ANTHROPIC_HTTP_TIMEOUT_SECONDS:-120}"

if [ -z "$PROMPT" ]; then
  echo "ERROR: missing prompt. Set AUDIT_PROMPT or pass prompt as first arg."
  exit 2
fi

if [ -z "$API_KEY" ]; then
  echo "ERROR: missing API key. Set ANTHROPIC_API_KEY."
  exit 2
fi

req_file="$(mktemp /tmp/anthropic_direct_req.XXXXXX.json)"
resp_file="$(mktemp /tmp/anthropic_direct_resp.XXXXXX.json)"
cleanup() {
  rm -f "$req_file" "$resp_file"
}
trap cleanup EXIT

python3 - "$MODEL" "$PROMPT" > "$req_file" <<'PY'
import json
import sys

model = sys.argv[1]
prompt = sys.argv[2]

payload = {
    "model": model,
    "max_tokens": 1800,
    "temperature": 0.1,
    "messages": [{"role": "user", "content": prompt}],
}
print(json.dumps(payload, ensure_ascii=False))
PY

curl -sS --max-time "$HTTP_TIMEOUT_SECONDS" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  "${BASE_URL}/messages" \
  -d @"$req_file" > "$resp_file"

python3 - "$resp_file" <<'PY'
import json
import sys

path = sys.argv[1]
raw = open(path, encoding="utf-8").read()

try:
    data = json.loads(raw)
except Exception:
    print(raw.strip())
    raise SystemExit(0)

if isinstance(data, dict) and data.get("error"):
    print(json.dumps(data, ensure_ascii=False))
    raise SystemExit(3)

content = data.get("content") if isinstance(data, dict) else None
if isinstance(content, list):
    chunks = []
    for part in content:
        if isinstance(part, dict) and part.get("type") == "text":
            txt = part.get("text")
            if isinstance(txt, str):
                chunks.append(txt)
    text = "\n".join(chunks).strip()
    if text:
        print(text)
        raise SystemExit(0)

print(json.dumps(data, ensure_ascii=False))
PY
