#!/bin/bash
cd terraform
terraform apply --var-file=dev.tfvars --auto-approve