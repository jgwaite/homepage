# josephwaite.ca Homepage Deployment Runbook

## Prereqs
- Node 18+
- AWS CLI with `us-east-1` default or `--region us-east-1`
- Terraform >= 1.6
 - Logged into the josephwaite AWS account (${AWS_ACCOUNT_ID:-<ACCOUNT_ID>})

_Note: All Terraform applies use the local backend inside `infra/envs/*`. Each environment keeps its own state directory._

## Local Secrets
- Run `./agents/scripts/extract-secrets.sh` once to create or refresh `agents/secrets.local.env`.
- Agents scripts automatically source `${SECRET_ENV:-agents/secrets.local.env}` when it exists.
- The secrets file is git-ignored and must never be committed.

## 1. Refresh Discovery Data
```
./agents/scripts/discover.sh
```
Review the output, update `agents/homepage-deploy-plan.md` if anything changed (new certs, zones, buckets, etc.).

## 2. Provision / Update Dev
```
(cd infra/envs/dev && terraform init)
(cd infra/envs/dev && terraform plan)
(cd infra/envs/dev && terraform apply)
```
- Leave `enable_aliases = false` until you are ready to wire `dev.josephwaite.ca`.
- When ready, set `enable_aliases = true` and confirm the ACM cert status is `ISSUED`:
  - `aws acm describe-certificate --region us-east-1 --certificate-arn <ACM_ARN> --query 'Certificate.Status'`

## 3. Deploy Dev Artifact
```
npm install
npm run build
./agents/scripts/deploy-dev.sh
```
- Script runs `aws s3 sync` and invalidates the dev CloudFront distribution.
- Verify:
  - `aws cloudfront get-distribution --id $(terraform -chdir=infra/envs/dev output -raw distribution_id) --query 'Distribution.Status'`
  - `curl -I https://$(terraform -chdir=infra/envs/dev output -raw distribution_domain_name)`

## 4. User Test
- Share the dev CloudFront domain with stakeholders.
- Optionally add temporary Route 53 records once aliases/cert are live and `enable_aliases` is flipped.

## 5. Promote to Prod
```
(cd infra/envs/prod && terraform init)
(cd infra/envs/prod && terraform plan)
(cd infra/envs/prod && terraform apply)
```
- Prod `terraform.tfvars` should keep `enable_aliases = false` until the `.ca` cutover. The `.com` redirect stays enabled by default (cert already issued).

## 6. Deploy Prod Artifact
```
npm run build
./agents/scripts/deploy-prod.sh
```
- Verify:
  - `aws cloudfront get-distribution --id $(terraform -chdir=infra/envs/prod output -raw distribution_id) --query 'Distribution.Status'`
  - `curl -I https://$(terraform -chdir=infra/envs/prod output -raw distribution_domain_name)`
  - `curl -I https://josephwaite.com` → expect `301` to `https://josephwaite.ca`.

## 7. Post-Certificate Flip (when pointing josephwaite.ca)
1. Edit `infra/envs/dev` and `infra/envs/prod` variables:
   - Set `enable_aliases = true` and ensure `acm_certificate_status = "ISSUED"`.
2. Re-run `terraform apply` in both envs.
3. Confirm DNS:
   - `aws route53 list-resource-record-sets --hosted-zone-id "${R53_ZONE_CA:-<HOSTED_ZONE_ID>}" --query "ResourceRecordSets[?Name=='josephwaite.ca.']"`
   - `dig NS josephwaite.ca +short`
   - `dig NS josephwaite.com +short`
   - `curl -I https://josephwaite.ca`
   - `curl -I https://dev.josephwaite.ca`

## 8. Helpful Terraform Outputs
- Dev bucket: `terraform -chdir=infra/envs/dev output -raw bucket_name`
- Dev distribution: `terraform -chdir=infra/envs/dev output -raw distribution_id`
- Prod bucket: `terraform -chdir=infra/envs/prod output -raw bucket_name`
- Prod distribution(s):
  - Site: `terraform -chdir=infra/envs/prod output -raw distribution_id`
  - Redirect: `terraform -chdir=infra/envs/prod output -raw redirect_distribution_id`

Keep scripts and Terraform outputs as the single source of truth—avoid manually editing AWS resources.
