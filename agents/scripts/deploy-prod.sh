#!/usr/bin/env bash
set -euo pipefail

SECRET_ENV="${SECRET_ENV:-agents/secrets.local.env}"
[[ -f "$SECRET_ENV" ]] && set -a && source "$SECRET_ENV" && set +a || true

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_DIR="$ROOT_DIR/infra/envs/prod"
REGION="${AWS_REGION:-us-east-1}"

bucket_name=$(terraform -chdir="$ENV_DIR" output -raw bucket_name)
distribution_id=$(terraform -chdir="$ENV_DIR" output -raw distribution_id)
distribution_domain=$(terraform -chdir="$ENV_DIR" output -raw distribution_domain_name 2>/dev/null || true)
redirect_domain=$(terraform -chdir="$ENV_DIR" output -raw redirect_distribution_domain 2>/dev/null || true)

if [[ -z "$bucket_name" || -z "$distribution_id" ]]; then
  echo "Terraform outputs missing. Run 'terraform apply' in infra/envs/prod first." >&2
  exit 1
fi

echo "Building Astro project..."
(cd "$ROOT_DIR" && npm run build)

echo "Syncing ./dist to s3://$bucket_name/"
aws s3 sync "$ROOT_DIR/dist" "s3://$bucket_name/" \
  --delete \
  --cache-control 'public,max-age=300' \
  --region "$REGION"

echo "Invalidating CloudFront distribution $distribution_id"
"$ROOT_DIR/agents/scripts/cf-invalidate.sh" "$distribution_id"

printf '\nProd primary: https://%s\n' "$distribution_domain"
if [[ -n "$redirect_domain" ]]; then
  printf 'Prod redirect (.com): https://%s\n' "$redirect_domain"
fi
