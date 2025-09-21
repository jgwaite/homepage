#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

if [[ $# -gt 0 ]]; then
  if [[ $1 = /* ]]; then
    OUTPUT_FILE="$1"
  else
    OUTPUT_FILE="$ROOT_DIR/$1"
  fi
else
  OUTPUT_FILE="$ROOT_DIR/agents/secrets.local.env"
fi

STATE_DEV="$ROOT_DIR/infra/envs/dev/terraform.tfstate"
STATE_PROD="$ROOT_DIR/infra/envs/prod/terraform.tfstate"
DOC_PLAN="$ROOT_DIR/agents/homepage-deploy-plan.md"
DOC_RUNBOOK="$ROOT_DIR/agents/runbook.md"

AWS_ACCOUNT_ID=""
ACM_CERT_ARN=""
R53_ZONE_CA=""
R53_ZONE_COM=""
DEV_BUCKET=""
DEV_CF_DIST_ID=""
DEV_CF_DOMAIN=""
PROD_BUCKET=""
PROD_CF_DIST_ID=""
PROD_CF_DOMAIN=""
REDIRECT_BUCKET=""
REDIRECT_CF_DIST_ID=""
REDIRECT_CF_DOMAIN=""
PRIMARY_DOMAIN="josephwaite.ca"
DEV_DOMAIN="dev.josephwaite.ca"
REDIRECT_DOMAIN="josephwaite.com"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

assign_if_empty() {
  local var_name="$1"
  local value="$2"
  if [[ -n "$value" ]]; then
    local existing
    existing=$(eval "printf '%s' \"\${$var_name}\"")
    if [[ -z "$existing" ]]; then
      eval "$var_name=\"\$value\""
    fi
  fi
}

jq_value() {
  local file="$1"
  local expr="$2"
  command_exists jq || return 1
  [[ -f "$file" ]] || return 1
  local result
  result=$(jq -r "$expr" "$file" 2>/dev/null || true)
  if [[ -z "$result" || "$result" == "null" ]]; then
    return 1
  fi
  printf '%s\n' "$result"
}

jq_value_with_arg() {
  local file="$1"
  local expr="$2"
  local arg_name="$3"
  local arg_value="$4"
  command_exists jq || return 1
  [[ -f "$file" ]] || return 1
  local result
  result=$(jq -r --arg "$arg_name" "$arg_value" "$expr" "$file" 2>/dev/null || true)
  if [[ -z "$result" || "$result" == "null" ]]; then
    return 1
  fi
  printf '%s\n' "$result"
}

first_match_from_files() {
  local pattern="$1"
  shift
  local file
  for file in "$@"; do
    [[ -f "$file" ]] || continue
    if command_exists rg; then
      local match
      match=$(rg --no-config -o -e "$pattern" -m 1 "$file" 2>/dev/null || true)
      if [[ -n "$match" ]]; then
        printf '%s\n' "$match"
        return 0
      fi
    fi
    if [[ -z "${match:-}" ]]; then
      match=$(grep -oE "$pattern" "$file" | head -n 1 || true)
      if [[ -n "$match" ]]; then
        printf '%s\n' "$match"
        return 0
      fi
    fi
  done
  return 1
}

extract_zone_from_docs() {
  local domain="$1"
  shift
  local pattern="${domain//./\\.}.*Z[0-9A-Z]{10,}"
  local file
  for file in "$@"; do
    [[ -f "$file" ]] || continue
    local line=""
    if command_exists rg; then
      line=$(rg --no-config -m 1 --no-line-number --no-filename "$pattern" "$file" 2>/dev/null || true)
    fi
    if [[ -z "$line" ]]; then
      line=$(grep -m1 -E "$pattern" "$file" || true)
    fi
    if [[ -n "$line" ]]; then
      local zone
      zone=$(printf '%s\n' "$line" | grep -oE 'Z[0-9A-Z]{10,}' | head -n 1 || true)
      if [[ -n "$zone" ]]; then
        printf '%s\n' "$zone"
        return 0
      fi
    fi
  done
  return 1
}

assign_if_empty "AWS_ACCOUNT_ID" "$(jq_value "$STATE_PROD" '([.resources[]? | select(.type=="aws_caller_identity") | .instances[0].attributes.account_id | select(.!="")][0]) // empty')"
assign_if_empty "AWS_ACCOUNT_ID" "$(jq_value "$STATE_DEV" '([.resources[]? | select(.type=="aws_caller_identity") | .instances[0].attributes.account_id | select(.!="")][0]) // empty')"
assign_if_empty "AWS_ACCOUNT_ID" "$(first_match_from_files '\\b[0-9]{12}\\b' "$DOC_PLAN" "$DOC_RUNBOOK")"

assign_if_empty "ACM_CERT_ARN" "$(jq_value "$STATE_PROD" '([.resources[]? | select(.type=="aws_cloudfront_distribution") | .instances[0].attributes.viewer_certificate[0].acm_certificate_arn | select(.!="")][0]) // empty')"
assign_if_empty "ACM_CERT_ARN" "$(jq_value "$STATE_DEV" '([.resources[]? | select(.type=="aws_cloudfront_distribution") | .instances[0].attributes.viewer_certificate[0].acm_certificate_arn | select(.!="")][0]) // empty')"
assign_if_empty "ACM_CERT_ARN" "$(first_match_from_files 'arn:aws:acm:[A-Za-z0-9:/._-]+' "$DOC_PLAN" "$DOC_RUNBOOK")"

assign_if_empty "DEV_BUCKET" "$(jq_value "$STATE_DEV" '.outputs.bucket_name.value // empty')"
assign_if_empty "DEV_CF_DIST_ID" "$(jq_value "$STATE_DEV" '.outputs.distribution_id.value // empty')"
assign_if_empty "DEV_CF_DOMAIN" "$(jq_value "$STATE_DEV" '.outputs.distribution_domain_name.value // empty')"

assign_if_empty "PROD_BUCKET" "$(jq_value "$STATE_PROD" '.outputs.bucket_name.value // empty')"
assign_if_empty "PROD_CF_DIST_ID" "$(jq_value "$STATE_PROD" '.outputs.distribution_id.value // empty')"
assign_if_empty "PROD_CF_DOMAIN" "$(jq_value "$STATE_PROD" '.outputs.distribution_domain_name.value // empty')"
assign_if_empty "REDIRECT_CF_DIST_ID" "$(jq_value "$STATE_PROD" '.outputs.redirect_distribution_id.value // empty')"
assign_if_empty "REDIRECT_CF_DOMAIN" "$(jq_value "$STATE_PROD" '.outputs.redirect_distribution_domain.value // empty')"

assign_if_empty "REDIRECT_BUCKET" "$(jq_value "$STATE_PROD" '([.resources[]? | select(.type=="aws_s3_bucket") | (.instances[0].attributes.bucket // empty) | select(. != "" and contains("redirect"))][0]) // empty')"
assign_if_empty "REDIRECT_BUCKET" "$(first_match_from_files 'jw-[a-z0-9-]*redirect-[a-z0-9]+' "$DOC_PLAN")"

assign_if_empty "R53_ZONE_CA" "$(jq_value_with_arg "$STATE_PROD" '([.resources[]? | select(.type=="aws_route53_record" and (.instances[0].attributes.name // "") == $domain) | .instances[0].attributes.zone_id | select(.!="")][0]) // empty' domain 'josephwaite.ca')"
assign_if_empty "R53_ZONE_CA" "$(jq_value_with_arg "$STATE_DEV" '([.resources[]? | select(.type=="aws_route53_record" and (.instances[0].attributes.name // "") == $domain) | .instances[0].attributes.zone_id | select(.!="")][0]) // empty' domain 'josephwaite.ca')"
assign_if_empty "R53_ZONE_CA" "$(extract_zone_from_docs 'josephwaite.ca' "$DOC_PLAN" "$DOC_RUNBOOK")"

assign_if_empty "R53_ZONE_COM" "$(jq_value_with_arg "$STATE_PROD" '([.resources[]? | select(.type=="aws_route53_record" and (.instances[0].attributes.name // "") == $domain) | .instances[0].attributes.zone_id | select(.!="")][0]) // empty' domain 'josephwaite.com')"
assign_if_empty "R53_ZONE_COM" "$(extract_zone_from_docs 'josephwaite.com' "$DOC_PLAN" "$DOC_RUNBOOK")"

mkdir -p "$(dirname "$OUTPUT_FILE")"

cat >"$OUTPUT_FILE" <<ENVVARS
AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID
ACM_CERT_ARN=$ACM_CERT_ARN
R53_ZONE_CA=$R53_ZONE_CA
R53_ZONE_COM=$R53_ZONE_COM
DEV_BUCKET=$DEV_BUCKET
DEV_CF_DIST_ID=$DEV_CF_DIST_ID
DEV_CF_DOMAIN=$DEV_CF_DOMAIN
PROD_BUCKET=$PROD_BUCKET
PROD_CF_DIST_ID=$PROD_CF_DIST_ID
PROD_CF_DOMAIN=$PROD_CF_DOMAIN
REDIRECT_BUCKET=$REDIRECT_BUCKET
REDIRECT_CF_DIST_ID=$REDIRECT_CF_DIST_ID
REDIRECT_CF_DOMAIN=$REDIRECT_CF_DOMAIN
PRIMARY_DOMAIN=$PRIMARY_DOMAIN
DEV_DOMAIN=$DEV_DOMAIN
REDIRECT_DOMAIN=$REDIRECT_DOMAIN
ENVVARS

printf 'Wrote %s with:\n' "$OUTPUT_FILE"
printf '  AWS_ACCOUNT_ID=%s\n' "$AWS_ACCOUNT_ID"
printf '  ACM_CERT_ARN=%s\n' "$ACM_CERT_ARN"
printf '  R53_ZONE_CA=%s\n' "$R53_ZONE_CA"
printf '  R53_ZONE_COM=%s\n' "$R53_ZONE_COM"
printf '  DEV_BUCKET=%s\n' "$DEV_BUCKET"
printf '  DEV_CF_DIST_ID=%s\n' "$DEV_CF_DIST_ID"
printf '  DEV_CF_DOMAIN=%s\n' "$DEV_CF_DOMAIN"
printf '  PROD_BUCKET=%s\n' "$PROD_BUCKET"
printf '  PROD_CF_DIST_ID=%s\n' "$PROD_CF_DIST_ID"
printf '  PROD_CF_DOMAIN=%s\n' "$PROD_CF_DOMAIN"
printf '  REDIRECT_BUCKET=%s\n' "$REDIRECT_BUCKET"
printf '  REDIRECT_CF_DIST_ID=%s\n' "$REDIRECT_CF_DIST_ID"
printf '  REDIRECT_CF_DOMAIN=%s\n' "$REDIRECT_CF_DOMAIN"
printf '  PRIMARY_DOMAIN=%s\n' "$PRIMARY_DOMAIN"
printf '  DEV_DOMAIN=%s\n' "$DEV_DOMAIN"
printf '  REDIRECT_DOMAIN=%s\n' "$REDIRECT_DOMAIN"
