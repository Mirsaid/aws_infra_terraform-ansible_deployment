# Provider configuration
terraform {

   backend "s3" {
     bucket         = "tfstate23123"
     key            = "tf-infra/terraform.tfstate"
     region         = "eu-central-1"
     dynamodb_table = "tfstate_db"
     encrypt        = true
   }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.59.0"
    }
  }

}

provider "aws" {
  region = "eu-central-1"
}

module "tf-state" {

  source      = "./modules/tf-state"
  bucket_name = "tfstate23123"
}


module "vpc" {

  source             = "./modules/vpc"
  vpc_cidr           = local.vpc_cidr
  public_subnet_cidr = local.public_subnet_cidr
  # ami_id             = local.ami_id
  # key_name           = local.key_name
  # instance_type      = local.instance_type
}



