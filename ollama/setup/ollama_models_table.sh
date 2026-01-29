#!/usr/bin/env bash
set -euo pipefail

MODELS_FILE="${1:-}"
if [[ -z "$MODELS_FILE" || ! -f "$MODELS_FILE" ]]; then
  echo "ERROR: Provide a models file. Example: $0 /path/to/models.txt" >&2
  exit 1
fi

export HOME="${HOME:-/root}"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Extract value from a line like:
# "    architecture        llama"
# Works with spaces OR tabs, and keys containing spaces.
get_kv() {
  local key="$1"
  awk -v k="$key" '
    $0 ~ "^[[:space:]]*" k "[[:space:]]+" {
      sub("^[[:space:]]*" k "[[:space:]]+", "", $0)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
      print
      exit
    }
  '
}

# Header (TSV)
printf "model\tarchitecture\tparameters\tcontext_length\tembedding_length\tquantization\tcapabilities\ttemperature\n"

while IFS= read -r model || [[ -n "${model:-}" ]]; do
  # Skip blanks/comments
  [[ -z "${model// /}" ]] && continue
  [[ "${model:0:1}" == "#" ]] && continue

  out="$(sudo ollama show "$model" 2>&1 || true)"

  if grep -qiE '^(Error:|panic:)' <<<"$out"; then
    # Put error message in capabilities column
    err="$(printf '%s' "$out" | head -n1 | tr '\t' ' ' | tr '\n' ' ')"
    printf "%s\t\t\t\t\t\t%s\t\n" "$model" "$err"
    continue
  fi

  arch="$(printf '%s\n' "$out" | get_kv "architecture")"
  params="$(printf '%s\n' "$out" | get_kv "parameters")"
  ctx="$(printf '%s\n' "$out" | get_kv "context length")"
  emb="$(printf '%s\n' "$out" | get_kv "embedding length")"
  quant="$(printf '%s\n' "$out" | get_kv "quantization")"
  temp="$(printf '%s\n' "$out" | get_kv "temperature")"

  # Capabilities list under "Capabilities" section
  caps="$(
    awk '
      /^  Capabilities/ {cap=1; next}
      cap && /^  [A-Za-z]/ {cap=0}         # next top-level section (e.g., "  Parameters")
      cap && /^[[:space:]]{4}[^[:space:]]/ {
        sub(/^[[:space:]]+/, "", $0)
        print
      }
    ' <<<"$out" | paste -sd, -
  )"

  printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
    "$model" "${arch:-}" "${params:-}" "${ctx:-}" "${emb:-}" "${quant:-}" "${caps:-}" "${temp:-}"

done < "$MODELS_FILE"
