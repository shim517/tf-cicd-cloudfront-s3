
data "aws_caller_identity" "current" {}

module "frontend" {
  source = "./modules/frontend"

  providers = {
    aws = aws
  }
  bucket_name = "${lower(local.project)}${lower(var.stage)}-frontend-${data.aws_caller_identity.current.account_id}"
  basic_auth = var.basic_auth
  prefix = "${lower(local.project)}${lower(var.stage)}-"
  acm_certificate_arn = var.acm_certificate_arn
  fqdn = var.fqdn
}
