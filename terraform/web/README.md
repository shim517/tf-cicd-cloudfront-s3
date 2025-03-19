# Overview

- Use `terraform workspace` to manage multiple environments.
- Create a shared cicd pipeline for all environments.

# Initialize

## Create S3 bucket and DynamoDB table for terraform state

```bash
aws s3api create-bucket --bucket myproject-terraform-state-$(aws sts get-caller-identity --query Account --output text) --region ap-southeast-1 --create-bucket-configuration LocationConstraint=ap-southeast-1
aws dynamodb create-table --table-name myproject-terraform-state-lock --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST
```

## Install terraform

```bash
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
mkdir ~/bin
ln -s ~/.tfenv/bin/* ~/bin/
tfenv install
tfenv use latest
terraform --version
```

## Deploy to staging

```bash
terraform -chdir=./terraform/web/ init
terraform -chdir=./terraform/web/ workspace select -or-create staging
terraform -chdir=./terraform/web/ plan -var-file='config/staging.tfvars' -var="update_cicd=false"
terraform -chdir=./terraform/web/ apply -var-file='config/staging.tfvars' -var="update_cicd=false"
terraform -chdir=./terraform/web/ output
```
