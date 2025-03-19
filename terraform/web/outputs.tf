output "frontend_s3_bucket_name" {
  value = module.frontend.s3_bucket_name
}

output "frontend_cloudfront_distribution_id" {
  value = module.frontend.cloudfront_distribution_id
}

output "frontend_cloudfront_domain_name" {
  value = module.frontend.cloudfront_domain_name
}
