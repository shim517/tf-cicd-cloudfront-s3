# About this repo

- This repo contains sample Terraform code and AWS CodeBuild buildspec files to create a website using S3 and CloudFront.
- This is the CI/CD component of another personal project.
- The original project contains a subfolder named `frontend`, which houses the website source code built with Next.js.
- Some CodeBuild spec files assume the source code is located in the `frontend` folder.

# Overview

## Architecture of the website
![web_architecture](./docs/web_architecture.drawio.svg)

Note:
- There are 2 AWS accounts: one for the website and another for Route 53.
- The website is hosted in an S3 bucket and distributed using CloudFront in the website account.
- Route 53 is configured in a separate account.
- Initially, I attempted to create a TLS certificate in the Route 53 account and share it with the website account, but this proved impossible. Therefore, I created the certificate in the website account instead.
  - See [this AWS discussion](https://repost.aws/questions/QUxxewbu3iQjqQghS-xD5O4w/cf-distro-and-acm-certificate-in-different-account)

## Architecture of the CI/CD pipeline

![cicd_architecture](./docs/cicd_architecture.drawio.svg)

Note:
- Uses Terraform as an IaC tool with backend storage in S3 and DynamoDB.
- Uses AWS CodeBuild for building and deploying the website.
- Implements `terraform workspace` to manage multiple environments.
- Combines `Project name` and `Stage name` as prefixes for resources to prevent name collisions between environments.
- Utilizes an S3 bucket as cache storage for CodeBuild.

# How to set up the CI/CD pipeline

\* I run the following commands in AWS CloudShell.  

1. Create S3 bucket and DynamoDB table for Terraform state.
    ```bash
    PROJECT_STAGE=  # your project name and stage name in lower case. e.g., my-best-project-stg, my-best-project-prod
    AWS_REGION=   # your AWS region
    aws s3api create-bucket --bucket $PROJECT_STAGE-terraform-state-$(aws sts get-caller-identity --query Account --output text) --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION
    aws dynamodb create-table --table-name $PROJECT_STAGE-terraform-state-lock --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST
    ```
    The S3 bucket and DynamoDB table are used to store Terraform state files.
2. Run the following commands to install Terraform.
    ```bash
    git clone https://github.com/tfutils/tfenv.git ~/.tfenv
    mkdir ~/bin
    ln -s ~/.tfenv/bin/* ~/bin/
    tfenv install
    tfenv use latest
    terraform --version
    ```
    I chose to use `tfenv` to manage Terraform versions.
3. Create the CI/CD pipeline.
    ```bash
    terraform -chdir=./terraform/cicd/ init
    terraform -chdir=./terraform/cicd/ workspace select -or-create cicd
    terraform -chdir=./terraform/cicd/ plan -var-file='config/cicd.tfvars'
    terraform -chdir=./terraform/cicd/ apply -var-file='config/cicd.tfvars'
    ```
    It creates a shared CI/CD pipeline for all environments.  
    Using workspace to isolate resources for CI/CD pipeline from the website resources.

# How to deploy the website

- You can deploy the website's infrastructure using the CI/CD pipeline just made in the previous step.
- Once you update main branch, the CI/CD pipeline will automatically deploy the infrastructure for the website and the website itself on it.
- See `.codebuild` folder for buildspec files used in the CI/CD pipeline.
