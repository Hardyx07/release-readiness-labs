variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  description = "Production node size (t2.micro is free-tier/test only)"
  type        = string
  default     = "t3.medium"
}

variable "node_count" {
  description = "Number of nodes - matches the 3 Kubernetes replicas"
  type        = number
  default     = 3
}

variable "ami_id" {
  description = "AMI for the cluster nodes"
  type        = string
}

variable "release_version" {
  type    = string
  default = "v2.3.0"
}

# No default value: supplied at runtime via TF_VAR_aws_secret_key or an IAM role.
variable "aws_secret_key" {
  type      = string
  sensitive = true
}
