#!/usr/bin/env bash
set -euo pipefail

SECRET_ENV="${SECRET_ENV:-agents/secrets.local.env}"
[[ -f "$SECRET_ENV" ]] && set -a && source "$SECRET_ENV" && set +a || true

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <distribution-id> [path...]" >&2
  exit 1
fi

DIST_ID="$1"
shift || true

if [[ $# -eq 0 ]]; then
  set -- "/*"
fi

echo "Invalidating paths $* on distribution ${DIST_ID}" >&2
aws cloudfront create-invalidation \
  --distribution-id "$DIST_ID" \
  --paths "$@" \
  --output table
