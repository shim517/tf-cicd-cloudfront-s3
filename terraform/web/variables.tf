variable "region" {
  description = "The AWS region to deploy to"
  type        = string
}

variable "update_cicd" {
  description = "Update CI/CD pipeline or not"
  type        = bool
}

variable "stage" {
  description = "The stage for the resources"
  type        = string
}

variable "basic_auth" {
  description = "Enable basic auth"
  type        = bool
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate. Must be in the same account as CloudFront distribution"
  type        = string
}

variable "fqdn" {
  description = "The FQDN of the CloudFront distribution"
  type        = string
}
