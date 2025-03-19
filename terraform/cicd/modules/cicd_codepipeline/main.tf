terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      configuration_aliases = [ aws.cicd ]
      version = ">= 2.7.0"
    }
  }
}

resource "aws_iam_role" "codepipeline_role" {
  provider = aws.cicd
  name = "${var.prefix}codepipeline-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_role_policy" {
  provider = aws.cicd
  name = "${var.prefix}codepipeline-role-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codestar-connections:UseConnection",
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "codebuild:StartBuild",
        "codebuild:BatchGetBuilds",
        "codecommit:GitPull",
        "cloudwatch:*",
        "logs:*",
        "sns:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_codestarconnections_connection" "github" {
  provider = aws.cicd
  provider_type = "GitHub"
  name = "${var.prefix}github-connection"
}

resource "aws_codepipeline" "pipeline" {
  provider = aws.cicd

  name     = "${var.prefix}pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = var.s3_bucket_name_prefix
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Download-Source"
      category         = "Source"
      owner            = "AWS"
      version          = "1"
      provider         = "CodeStarSourceConnection"
      namespace        = "SourceVariables"
      output_artifacts = ["SourceOutput"]
      run_order        = 1

      configuration = {
        ConnectionArn = aws_codestarconnections_connection.github.arn
        FullRepositoryId = var.source_repo_name
        BranchName = var.source_repo_branch
      }
    }
  }

  dynamic "stage" {
    for_each = var.stages

    content {
      name = "Stage-${stage.value["name"]}"
      action {
        category         = stage.value["category"]
        name             = "Action-${stage.value["name"]}"
        owner            = stage.value["owner"]
        provider         = stage.value["provider"]
        input_artifacts  = stage.value["input_artifacts"] != null ? [stage.value["input_artifacts"]] : []
        output_artifacts = stage.value["output_artifacts"] != null ? [stage.value["output_artifacts"]] : []
        version          = "1"
        run_order        = index(var.stages, stage.value) + 2

        configuration = {
          ProjectName = stage.value["provider"] == "CodeBuild" ? stage.value["codebuild_project"] : null
        }
      }
    }
  }

}
