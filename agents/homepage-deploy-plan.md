# josephwaite.ca Homepage Deployment Plan

## 1. Discovery Summary (us-east-1)

### Route 53 Hosted Zones
- `josephwaite.ca` — `/hostedzone/<HOSTED_ZONE_ID_CA>`, 3 records today.
- `josephwaite.com` — `/hostedzone/<HOSTED_ZONE_ID_COM>`, 3 records today.
- Additional hosted zone observed (`myforge.fit`) will remain untouched.

### ACM Certificates (CloudFront region)
- Issued multi-domain cert covering `josephwaite.ca`, `*.josephwaite.ca`, `josephwaite.com`, `*.josephwaite.com`.
  - ARN: `arn:aws:acm:us-east-1:<ACCOUNT_ID>:certificate/<CERT_ID>`.
  - Status: `ISSUED` on 2025-09-20. Safe to reuse for all CloudFront aliases.
- Unrelated cert in use for `myforge.fit`; leave untouched.

### S3 Buckets (collision check)
- Existing buckets: `app.myforge.fit`, `forge-dev-landing`, `forge-prod-landing`, `myforge-dev-frontend-<ACCOUNT_ID>`, `myforge-prod-frontend-<ACCOUNT_ID>`, `myforge.fit`.
- No `jw-home-*` buckets yet — safe to create new names with random suffix.

### CloudFront Distributions
- `<DISTRIBUTION_ID>` (`<CF_DOMAIN>`) — myforge.dev landing.
- `<DISTRIBUTION_ID>` (`<CF_DOMAIN>`) — myforge prod (details truncated, leave untouched).
- No josephwaite distributions today — our infra will create new ones.

## 2. Target Terraform Architecture
- **Providers**: Local backend; single AWS provider pinned to `us-east-1`.
- **Modules**:
  - `s3_site`: private S3 bucket, SSE-S3, website objects served only through a CloudFront Origin Access Control (OAC), optional `index.html` placeholder.
  - `cf_dist`: CloudFront distribution fronting the `s3_site` bucket via OAC. Defaults to CloudFront cert, exposes variables for aliases + ACM ARN later.
  - `redirect_site`: S3 website-redirect bucket + CloudFront distribution with required alias/cert. Handles `josephwaite.com` → `https://josephwaite.ca`.
- **Environments** (`infra/envs/{dev,prod}`): instantiate modules, supply randomised bucket names, output bucket + distribution IDs, allow optional alias/cert wiring controlled via variables.
- **Route53**: records created only when the corresponding ACM cert status is `ISSUED` *and* aliases are enabled, ensuring noop until ready. `.com` redirect creates ALIAS immediately using issued cert.
- **Tagging**: every resource tagged with `Project=josephwaite-homepage`, `Environment`, `ManagedBy=Terraform`, `Owner=joseph.waite`.

## 3. Planned Repository Layout
```
infra/
  main.tf
  providers.tf
  versions.tf
  variables.tf
  outputs.tf
  modules/
    s3_site/
      main.tf
      variables.tf
      outputs.tf
    cf_dist/
      main.tf
      variables.tf
      outputs.tf
    redirect_site/
      main.tf
      variables.tf
      outputs.tf
  envs/
    dev/
      main.tf
      variables.tf
      outputs.tf
      terraform.tfvars.example
    prod/
      main.tf
      variables.tf
      outputs.tf
      terraform.tfvars.example
```

## 4. Runbook Overview (detail in `./agents/runbook.md`)
1. Build Astro: `npm run build`.
2. Sync to target bucket: `aws s3 sync ./dist s3://<bucket>/ --delete --cache-control 'public,max-age=300'`.
3. Invalidate distribution: `aws cloudfront create-invalidation --distribution-id <CF_ID> --paths "/*"`.
4. Smoke-test via CloudFront domain, then apex alias once certs applied.
5. Promote by repeating steps against prod resources.
6. `.com` redirect check: `curl -I https://josephwaite.com` → expect 301 to `https://josephwaite.ca`.

## 5. Blockers / Notes
- ACM cert for both domains already `ISSUED`; no blocker. Terraform will take ARN via variable so it can be toggled on when ready to cut aliases.
- Route53 alias records will be created conditionally to avoid premature DNS flips.
- Ensure helper scripts load target IDs from `terraform output` or tfvars to avoid hard-coding once deployed.

## 6. Terraform Plan Summaries
- `infra/envs/dev`: **9 to add / 0 change / 0 destroy.** Provisions a private `jw-home-dev-<suffix>` S3 bucket (SSE-S3 + blocked public access), uploads a placeholder `index.html`, attaches a CloudFront OAC policy limited to the new distribution, and spins up a default-certificate CloudFront distribution (no aliases yet). Route 53 ALIAS records remain deferred until `enable_aliases = true`.
- `infra/envs/prod`: **16 to add / 0 change / 0 destroy.** Same site stack for `jw-home-prod-<suffix>` plus the `.com` redirect: creates the redirect website bucket, CloudFront distribution with the issued multi-domain ACM cert, and Route 53 ALIAS records for `josephwaite.com`. Prod aliases for `josephwaite.ca` stay gated behind `enable_aliases`/`acm_certificate_status`.

## 7. Verification Commands
- `aws acm describe-certificate --certificate-arn <ARN> --region us-east-1 --query 'Certificate.Status'`
- `aws cloudfront get-distribution --id <DIST_ID> --query 'Distribution.Status'`
- `aws route53 list-resource-record-sets --hosted-zone-id <ZONE_ID>`
- `dig NS josephwaite.ca +short`
- `dig NS josephwaite.com +short`
- `curl -I https://<cf-domain>.cloudfront.net`

## 8. Next Steps
- Scaffold Terraform as outlined above.
- Run `terraform init && terraform plan` in `infra/envs/dev` and `infra/envs/prod`, capture deltas in §6.
- Implement helper scripts for discovery + deployments.
