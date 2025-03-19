# About this repo

- This repo is sample Terraform and AWS CodeBuild buildspec file to create a website using S3 and CloudFront.
- This is the CI/CD part of my another personal project.
- The original project contains subfolder named `frontend`, which contains the website source code using Next.js.
- So some of the codebuild spec file is assuming the source code is in `frontend` folder.

# Overview

## Architecture of the website
![web_architecture](./docs/web_architecture.drawio.svg)

Note:
- There are 2 AWS accounts. One for the website and another for Route 53.
- The website is hosted in S3 bucket and distributed using CloudFront on the website account.
- The Route 53 is in the other account.
- At first, I tried to make TLS certificate in the Route 53 account and share it to the website account. But it seems not possible. So I created the certificate in the website account.
  - See [https://repost.aws/questions/QUxxewbu3iQjqQghS-xD5O4w/cf-distro-and-acm-certificate-in-different-account](https://repost.aws/questions/QUxxewbu3iQjqQghS-xD5O4w/cf-distro-and-acm-certificate-in-different-account)


## Architecture of the CI/CD pipeline

![cicd_architecture](./docs/cicd_architecture.drawio.svg)

Note:
- Use Terraform as an IaC tool with its backend in S3 and DynamoDB.
- Use AWS CodeBuild to build and deploy the website.
- Use `terraform workspace` to manage multiple environments.
- Use the combination of `Project name` and `Stage name` as the prefix for the resources to avoid name collision between environments.
- Use S3 bucket as cache storage used by CodeBuild.
