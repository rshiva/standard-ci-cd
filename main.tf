terraform {
  required_version = ">=1.14.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>5.92"
    }
  }
}

module "vpc" {
  source = "./modules/vpc"
}

module "eks" {
  source = "./modules/eks"
  private_subnet_ids = module.vpc.private_subnet_ids
}


provider "aws" {
  region = var.aws_region
  
}