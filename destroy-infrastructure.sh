#!/bin/bash
cd terraform
terraform destroy --var-file=dev.tfvars --auto-approve