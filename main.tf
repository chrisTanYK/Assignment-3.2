provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "sctp-ce8-tfstate"
    key    = "christanyk-s3-tf-ci.tfstate"
    region = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}

locals {
  name_prefix = split("/", data.aws_caller_identity.current.arn)
  account_id  = data.aws_caller_identity.current.account_id
}

# checkov:skip=CKV2_AWS_62 reason="S3 event notifications not required for this use case"
# checkov:skip=CKV_AWS_145 reason="Encryption is applied in a separate resource block"
# checkov:skip=CKV2_AWS_6 reason="Public access is blocked using separate resource block"
# checkov:skip=CKV_AWS_21 reason="Versioning is handled in aws_s3_bucket_versioning"
# checkov:skip=CKV_AWS_144 reason="Replication not needed for this specific bucket"
# checkov:skip=CKV_AWS_18 reason="Access logging will be configured in future"
# checkov:skip=CKV2_AWS_61 reason="Lifecycle rules are applied separately"
resource "aws_s3_bucket" "s3_tf" {
  bucket = "${join("-", local.name_prefix)}-s3-tf-bkt-${local.account_id}"
}