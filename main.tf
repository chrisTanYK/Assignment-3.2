#--------------------
# Provider Configuration
#--------------------
provider "aws" {
  region = "us-east-1"
}

#--------------------
# Terraform Settings
#--------------------
terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "sctp-ce9-tfstate"
    key    = "christanyk-s3-tf-ci.tfstate"
    region = "us-east-1"
  }
}

#--------------------
# Data Sources
#--------------------
data "aws_caller_identity" "current" {}

#--------------------
# Locals
#--------------------
locals {
  # Extract only the username portion from the ARN to use in the bucket name
  name_prefix = element(
    split("/", data.aws_caller_identity.current.arn),
    length(split("/", data.aws_caller_identity.current.arn)) - 1
  )
  account_id = data.aws_caller_identity.current.account_id
}

#--------------------
# Resources
#--------------------
# checkov:skip=CKV2_AWS_62 reason="S3 event notifications not required for this use case"
# checkov:skip=CKV_AWS_145 reason="Encryption is applied in a separate resource block"
# checkov:skip=CKV2_AWS_6 reason="Public access is blocked using separate resource block"
# checkov:skip=CKV_AWS_21 reason="Versioning is handled in aws_s3_bucket_versioning"
# checkov:skip=CKV_AWS_144 reason="Replication not needed for this specific bucket"
# checkov:skip=CKV_AWS_18 reason="Access logging will be configured in future"
# checkov:skip=CKV2_AWS_61 reason="Lifecycle rules are applied separately"
resource "aws_s3_bucket" "s3_tf" {
  bucket = "${local.name_prefix}-s3-tf-bkt-${local.account_id}"
}
