variable "region" {
  description = "AWS region"
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones for the subnets"
  type        = list(string)
}

variable "vpc_subnet" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_public_subnets" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
}

variable "vpc_private_subnets" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
}

variable "node_subnet" {
  description = "CIDR block for the node subnet"
  type        = string
}

variable "pod_subnet" {
  description = "CIDR block for the pod subnet"
  type        = string
}

variable "netmaker_ami" {
  description = "AMI ID for the Netmaker instance"
  type        = string
}

variable "netmaker_key" {
  description = "Name of the EC2 key pair"
  type        = string
}
