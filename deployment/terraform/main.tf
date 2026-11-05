# Production runtime is Kubernetes (deployment/kubernetes/).
# This Terraform provisions the production worker nodes for that cluster.
# AWS credentials come from environment variables / IAM role - never from code.

provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "app_node" {
  count         = var.node_count
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name        = "orderflow-prod-node-${count.index + 1}"
    Environment = "production"
    Version     = var.release_version
  }
}
