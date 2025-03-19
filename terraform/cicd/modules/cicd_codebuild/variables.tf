variable "codebuild_project_suffix" {
  description = "The name of the project"
  type        = string
}

variable "prefix" {
  description = "Prefix to be added to the project name"
  type        = string
}

variable "cache_s3_bucket_name_prefix" {
  description = "The name of the S3 bucket to use for caching"
  type        = string
}

variable "buildspec_path" {
  description = "The path to the buildspec file"
  type        = string
}

variable "tf_backend_dynamodb_table" {
  description = "The name of the DynamoDB table for Terraform backend"
  type        = string
}
