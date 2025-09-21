provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "josephwaite-homepage"
      ManagedBy = "Terraform"
      Owner     = "joseph.waite"
    }
  }
}
