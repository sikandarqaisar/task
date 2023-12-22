# Terraform AWS Infrastructure

This repository contains Terraform templates to provision and manage the following AWS resources:

- ALB (Application Load Balancer)
- VPC (Virtual Private Cloud)
- AutoScaling
- CodePipeline
- IAM Role
- S3 (Simple Storage Service)
- SecurityGroup

## Prerequisites

Before you begin, ensure you have the following:

- [Terraform](https://www.terraform.io/) installed on your machine.
- AWS credentials configured with the necessary permissions.

## Project Structure

```plaintext
.
├── alb.tf
├── vpc.tf
├── autoscaling.tf
├── codepipeline.tf
├── iam_role.tf
├── s3.tf
├── security_group.tf
├── deploy-infrastructure.sh
├── destroy-infrastructure.sh
├── update_to_carol.sh
├── revert_to_frank.sh
└── variables.tf

## Usage
Clone the Repository:

git clone https://github.com/sikandarqaisar/task
cd terraform
Set AWS Credentials:


## Create Infrastructure:

Run the deployment script to create the infrastructure:
./deploy-infrastructure.sh

Update Code on EC2:

To update code directly on an EC2 instance, run:

./update_to_carol.sh

Revert Code to Frank:

To revert code to Frank on an EC2 instance, run:

./revert_to_frank.sh
Destroy Infrastructure:

After using the infrastructure, run the destroy script to clean up resources:

./destroy-infrastructure.sh
