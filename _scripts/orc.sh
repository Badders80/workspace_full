#!/bin/bash
# ═══════════════════════════════════════════════════════════
# orc - OpenRouter CLI with DNA Context
# Universal Model-Agnostic Memory System
# ═══════════════════════════════════════════════════════════

EVO_ROOT="/home/evo"

# Load API Key from master .env
if [ -f "$EVO_ROOT/.env" ]; then
    export $(grep OPENROUTER_API_KEY "$EVO_ROOT/.env" | xargs)
fi

if [ -z "$OPENROUTER_API_KEY" ]; then
    echo "❌ Error: OPENROUTER_API_KEY not found in $EVO_ROOT/.env"
    exit 1
fi

# Model Mappings
case "${1:-sonnet}" in
    haiku)  MODEL="qwen/qwen-2.5-coder-32b-instruct" ;;
    sonnet) MODEL="moonshotai/kimi-k2" ;;
    opus)   MODEL="deepseek/deepseek-r1" ;;
    *)      MODEL="$1" ;;
esac
shift

# Handle Prompt (Args or Stdin)
if [ $# -gt 0 ]; then
    USER_PROMPT="$*"
else
    # Read from stdin if no args provided
    USER_PROMPT=$(cat)
fi

if [ -z "$USER_PROMPT" ]; then
    echo "Usage: orc [haiku|sonnet|opus|model_id] "your prompt""
    echo "       echo "your prompt" | orc sonnet"
    exit 0
fi

# Prepare DNA Context
DNA_CONTEXT=$(bash "$EVO_ROOT/_scripts/dna-context.sh" 2>/dev/null)

# Prepare JSON payload (using python3 for safe escaping if jq is missing)
# But since we want it fast and robust, we'll try to use a heredoc pattern or python
FULL_PROMPT="MANDATORY DNA CONTEXT:
$DNA_CONTEXT

---
USER REQUEST:
$USER_PROMPT"

echo "🧠 Querying OpenRouter ($MODEL)..."

# Use python3 to send the request (pre-installed on most systems and handles JSON well)
python3 - <<EOF
import json
import urllib.request
import os

api_key = os.environ.get("OPENROUTER_API_KEY")
model = "$MODEL"
prompt = """$FULL_PROMPT"""

url = "https://openrouter.ai/api/v1/chat/completions"
headers = {
    "Authorization": f"Bearer {api_key}",
    "Content-Type": "application/json",
    "HTTP-Referer": "https://evolution-stables.local",
    "X-Title": "Evo-Orc-CLI"
}

data = {
    "model": model,
    "messages": [
        {"role": "user", "content": prompt}
    ]
}

try:
    req = urllib.request.Request(url, data=json.dumps(data).encode(), headers=headers)
    with urllib.request.urlopen(req) as response:
        res_data = json.loads(response.read().decode())
        content = res_data['choices'][0]['message']['content']
        print(content)
except Exception as e:
    print(f"❌ Error: {str(e)}")
EOF
