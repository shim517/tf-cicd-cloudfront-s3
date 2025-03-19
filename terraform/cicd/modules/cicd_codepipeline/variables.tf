#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

variable "codebuild_project" {
  description = "Unique name for this project"
  type        = string
}

variable "source_repo_name" {
  description = "Source repo name of the GitHub repository. e.g., aws-samples/aws-cdk-examples"
  type        = string
}

variable "source_repo_branch" {
  description = "Default branch in the Source repo for which CodePipeline needs to be configured"
  type        = string
}

variable "s3_bucket_name_prefix" {
  description = "S3 bucket name to be used for storing the artifacts"
  type        = string
}

variable "stages" {
  description = "List of Map containing information about the stages of the CodePipeline"
  type        = list(map(any))
}

variable "prefix" {
  description = "Prefix to be added to the project name"
  type        = string
}
