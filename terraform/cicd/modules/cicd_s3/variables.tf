variable "bucket_name_suffix" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "delete_in_days" {
  description = "Number of days after which the objects in the bucket should be deleted"
  type        = number
  default     = 30
}

variable "prefix" {
  description = "Prefix to be added to the bucket name"
  type        = string
}

variable "region" {
  description = "The AWS region to deploy to"
  type        = string
}
