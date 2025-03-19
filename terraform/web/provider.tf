terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "myproject-terraform-state-<account_id>" # NOTE: Replace <account_id> with your AWS account ID
    key            = "terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "myproject-terraform-state-lock"
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = var.region

  default_tags {
    tags = {
      Project = local.project
      Stage = var.stage
    }
  }
}
