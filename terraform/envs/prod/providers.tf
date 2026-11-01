terraform {

  required_version = ">= 1.16"
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = ">= 6.0"
    }
  }

  backend "s3" {
    bucket                      = "tfstate"
    key                         = "prod/terraform.tfstate"
    region                      = "ap-south-1"
    use_lockfile                = true
    endpoints                   = { s3 = "http://localhost:4566" }
    use_path_style              = true
    access_key                  = "test"
    secret_key                  = "test"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
}

variable "env" {
  type    = string
  default = "prod"
}

variable "aws_endpoint" {
  type    = string
  default = "http://localhost:4566"
}

provider "aws" {
  region                      = "ap-south-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3             = var.aws_endpoint
    sqs            = var.aws_endpoint
    iam            = var.aws_endpoint
    sts            = var.aws_endpoint
    secretsmanager = var.aws_endpoint
    lambda         = var.aws_endpoint
    ecs            = var.aws_endpoint
    ecr            = var.aws_endpoint
    route53        = var.aws_endpoint
    cloudwatch     = var.aws_endpoint
    logs           = var.aws_endpoint
    sns            = var.aws_endpoint
    budgets        = var.aws_endpoint
    ec2            = var.aws_endpoint
  }

  default_tags {
    tags = {
      Project     = "k8s-platform-lab",
      Environment = var.env,
      ManagedBy   = "terraform",
      Owner       = "ujjaval"
    }
  }
}
