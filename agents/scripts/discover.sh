#!/usr/bin/env bash
set -euo pipefail

SECRET_ENV="${SECRET_ENV:-agents/secrets.local.env}"
[[ -f "$SECRET_ENV" ]] && set -a && source "$SECRET_ENV" && set +a || true

REGION="${AWS_REGION:-us-east-1}"

header() {
  printf '\n=== %s ===\n' "$1"
}

header "Route 53 Hosted Zones"
aws route53 list-hosted-zones-by-name --dns-name josephwaite.ca --max-items 1 --output table
aws route53 list-hosted-zones-by-name --dns-name josephwaite.com --max-items 1 --output table

header "ACM Certificates in ${REGION}"
aws acm list-certificates \
  --region "$REGION" \
  --certificate-statuses ISSUED PENDING_VALIDATION \
  --query "CertificateSummaryList[?contains(DomainName, 'josephwaite') || contains(SubjectAlternativeNameSummaries, 'josephwaite.ca') || contains(SubjectAlternativeNameSummaries, 'josephwaite.com')]" \
  --output table

mapfile -t CERT_ARNS < <(aws acm list-certificates \
  --region "$REGION" \
  --certificate-statuses ISSUED PENDING_VALIDATION \
  --query "CertificateSummaryList[?contains(DomainName, 'josephwaite') || contains(SubjectAlternativeNameSummaries, 'josephwaite.ca') || contains(SubjectAlternativeNameSummaries, 'josephwaite.com')].CertificateArn" \
  --output text | tr '\t' '\n' | sort -u)

if [[ ${#CERT_ARNS[@]} -gt 0 ]]; then
  for arn in "${CERT_ARNS[@]}"; do
    [[ -z "$arn" ]] && continue
    header "Certificate $arn"
    aws acm describe-certificate \
      --region "$REGION" \
      --certificate-arn "$arn" \
      --query "Certificate.{Domain:DomainName,Status:Status,NotAfter:NotAfter,SANs:SubjectAlternativeNames}" \
      --output table
  done
else
  echo "No josephwaite certificates found in $REGION"
fi

header "S3 Buckets (possible name collisions)"
aws s3api list-buckets \
  --query "Buckets[?contains(Name, 'joseph') || contains(Name, 'jw') || contains(Name, 'home')].Name" \
  --output table

header "All S3 buckets"
aws s3api list-buckets --query 'Buckets[].Name' --output table

header "CloudFront Distributions"
aws cloudfront list-distributions \
  --query "DistributionList.Items[].{Id:Id,Domain:DomainName,Comment:Comment,Aliases:Aliases.Items}" \
  --output table
