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
