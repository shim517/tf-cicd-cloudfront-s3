terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      configuration_aliases = [ aws.cicd ]
      version = ">= 2.7.0"
    }
  }
}

resource "aws_s3_bucket" "artifact_bucket" {
  provider = aws.cicd
  bucket = "${var.prefix}${var.bucket_name_suffix}"

  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "aws_s3_bucket_lifecycle_configuration" "artifact_bucket_lifecycle" {
  provider = aws.cicd
  bucket = aws_s3_bucket.artifact_bucket.id

  rule {
    id     = "delete-objects"
    status = "Enabled"

    expiration {
      days = var.delete_in_days
    }
  }
}
