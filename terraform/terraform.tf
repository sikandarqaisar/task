terraform { 
  backend "s3" { 
    bucket         = "config-bucket-059516066038" 
    region         = "us-east-1" 
    key            = "task/terraform/terraform.tfstate" 
  }
}