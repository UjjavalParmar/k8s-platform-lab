locals {
  name = "lab-${var.env}"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.7"

  name               = local.name
  cidr               = "10.0.0.0/16"
  azs                = ["ap-south-1a", "ap-south-1b"]
  private_subnets    = ["10.0.0.0/19", "10.0.32.0/19"]
  public_subnets     = ["10.0.64.0/24", "10.0.65.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
}

resource "aws_sqs_queue" "jobs_dlq" {
  name                      = "${local.name}-jobs-dlq"
  message_retention_seconds = 1209600
}

resource "aws_sqs_queue" "jobs" {
  name                       = "${local.name}-jobs"
  visibility_timeout_seconds = 60
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.jobs_dlq.arn,
    maxReceiveCount     = 3
  })
}

resource "aws_s3_bucket" "backups" {
  bucket = "${local.name}-backups"
}

resource "aws_ecr_repository" "app" {
  for_each             = toset(["api", "worker"])
  name                 = "${local.name}/${each.key}"
  image_tag_mutability = "IMMUTABLE"
}

output "jobs_queue_url" {
  value = aws_sqs_queue.jobs.url
}
