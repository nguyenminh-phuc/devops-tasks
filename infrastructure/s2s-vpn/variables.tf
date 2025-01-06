variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "availability_zones" {
  description = "Availability Zones for the subnets"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "vpc_subnet" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.226.0.0/16"
}

variable "vpc_public_subnets" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.226.1.0/24", "10.226.2.0/24"]
}

variable "vpc_private_subnets" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.226.3.0/24", "10.226.4.0/24"]
}

variable "customer_gateway_ip" {
  description = "Public IP address for the customer gateway"
  type        = string
}

variable "customer_subnets" {
  description = "CIDR blocks for the customer's private network"
  type        = list(string)
  default     = ["10.80.0.0/16", "10.85.0.0/16"]
}
