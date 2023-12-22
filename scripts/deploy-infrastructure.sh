#!/bin/bash
cd ../terraform
terraform init
terraform apply --var-file=dev.tfvars --auto-approve