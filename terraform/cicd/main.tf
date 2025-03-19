
# /home/ubuntu/dev/myproject-web/terraform/main.tf
provider "aws" {
  alias  = "cicd"
  region = local.cicd_region
}

data "aws_caller_identity" "current" {}

module "cicd_artifact" {
  source = "./modules/cicd_s3"

  providers = {
    aws.cicd = aws.cicd
  }

  bucket_name_suffix = "cicd-artifact-${data.aws_caller_identity.current.account_id}"
  prefix = "${lower(local.project)}-"
  region = local.cicd_region
}

module "cicd_codebuild_main_branch" {
  source = "./modules/cicd_codebuild"

  providers = {
    aws.cicd = aws.cicd
  }

  prefix = "${lower(local.project)}-"
  codebuild_project_suffix = "codebuild"
  cache_s3_bucket_name_prefix = "${module.cicd_artifact.s3_bucket_name}/codebuild/cache"
  buildspec_path = ".codebuild/buildspec_main.yml"
  tf_backend_dynamodb_table = local.tf_backend_dynamodb_table
}

module "cicd_codebuild_main_deploy" {
  source = "./modules/cicd_codebuild"

  providers = {
    aws.cicd = aws.cicd
  }

  prefix = "${lower(local.project)}-main-deploy-"
  codebuild_project_suffix = "codebuild-deploy"
  cache_s3_bucket_name_prefix = "${module.cicd_artifact.s3_bucket_name}/codebuild/cache"
  buildspec_path = ".codebuild/buildspec_main_deploy.yml"
  tf_backend_dynamodb_table = local.tf_backend_dynamodb_table
}

module "codepipeline" {
  source = "./modules/cicd_codepipeline"

  providers = {
    aws.cicd = aws.cicd
  }

  prefix = "${lower(local.project)}-"
  codebuild_project = module.cicd_codebuild_main_branch.codebuild_project_name
  source_repo_name = "shim517/myproject-web" # NOTE: Replace with your GitHub username and repository name
  source_repo_branch = "main"
  s3_bucket_name_prefix = "${module.cicd_artifact.s3_bucket_name}"
  stages = [
    {
      name = "build",
      category = "Build",
      owner = "AWS",
      provider = "CodeBuild",
      input_artifacts = "SourceOutput",
      output_artifacts = "BuildOutput",
      codebuild_project = module.cicd_codebuild_main_branch.codebuild_project_name
    },
    {
      name = "ManualApproval",
      category = "Approval",
      owner = "AWS",
      provider = "Manual",
      input_artifacts = null,
      output_artifacts = null,
      codebuild_project = null
    },
    {
      name = "Deploy",
      category = "Build",
      owner = "AWS",
      provider = "CodeBuild",
      input_artifacts = "BuildOutput",
      output_artifacts = "DeployOutput",
      codebuild_project = module.cicd_codebuild_main_deploy.codebuild_project_name
    }
  ]
}
