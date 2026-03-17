#!/usr/bin/env bash
set -euo pipefail

MODEL="${GLM_AUDIT_MODEL:-z-ai/glm-4.7-flash}"
BASE_URL="${ZAI_BASE_URL:-https://api.z.ai/api/paas/v4}"
API_KEY="${ZAI_API_KEY:-${OPENAI_API_KEY:-}}"
PROMPT="${AUDIT_PROMPT:-${1:-}}"
HTTP_TIMEOUT_SECONDS="${GLM_HTTP_TIMEOUT_SECONDS:-120}"

# Accept provider-prefixed IDs (e.g., "z-ai/glm-4.7-flash") and normalize to raw API model code.
REQUEST_MODEL="$MODEL"
if [[ "$REQUEST_MODEL" == */* ]]; then
  REQUEST_MODEL="${REQUEST_MODEL#*/}"
fi

if [ -z "$PROMPT" ]; then
  echo "ERROR: missing prompt. Set AUDIT_PROMPT or pass prompt as first arg."
  exit 2
fi

if [ -z "$API_KEY" ]; then
  echo "ERROR: missing API key. Set ZAI_API_KEY or OPENAI_API_KEY."
  exit 2
fi

req_file="$(mktemp /tmp/glm_direct_req.XXXXXX.json)"
resp_file="$(mktemp /tmp/glm_direct_resp.XXXXXX.json)"
cleanup() {
  rm -f "$req_file" "$resp_file"
}
trap cleanup EXIT

python3 - "$REQUEST_MODEL" "$PROMPT" > "$req_file" <<'PY'
import json
import sys

model = sys.argv[1]
prompt = sys.argv[2]

payload = {
    "model": model,
    "messages": [{"role": "user", "content": prompt}],
    "temperature": 0.1,
}
print(json.dumps(payload, ensure_ascii=False))
PY

curl -sS --max-time "$HTTP_TIMEOUT_SECONDS" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  "${BASE_URL}/chat/completions" \
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

if isinstance(data, dict) and "error" in data:
    print(json.dumps(data, ensure_ascii=False))
    raise SystemExit(3)

choices = data.get("choices") if isinstance(data, dict) else None
if isinstance(choices, list) and choices:
    first = choices[0]
    if isinstance(first, dict):
        msg = first.get("message")
        if isinstance(msg, dict):
            content = msg.get("content")
            if isinstance(content, str) and content.strip():
                print(content.strip())
                raise SystemExit(0)

print(json.dumps(data, ensure_ascii=False))
PY
