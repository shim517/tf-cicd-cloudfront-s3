variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "basic_auth" {
  description = "Enable basic auth"
  type        = bool
}

variable "prefix" {
  description = "Prefix to be added to the project name"
  type        = string
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate. Must be in the same account as CloudFront distribution"
  type        = string  
}

variable "fqdn" {
  description = "The FQDN of the CloudFront distribution"
  type        = string
}
