variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-west-2"
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

variable "key_name" {
  description = "Name of AWS key pair"
}

variable "instance_type" {
  default     = "t2.small"
  description = "AWS instance type"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default     = "1"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default     = "2"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default     = "1"
}

variable "service_desired" {
  description = "Desired numbers of instances in the ecs service"
  default     = "1"
}

variable "bastion_ssh_from" {
  description = "CIDR block allowed to ssh to bastion"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  default = "10.0.0.0/16"
}

variable "ingress_subnet_az_1_CIDR" {
  description = "Ingress Subnet AZ 1 CIDR"
  default = "10.0.1.0/24"
}

variable "ingress_subnet_az_2_CIDR" {
  description = "Ingress Subnet AZ 1 CIDR"
  default = "10.0.2.0/24"
}

variable "private_subnet_az_1_CIDR" {
  description = "Ingress Subnet AZ 1 CIDR"
  default = "10.0.3.0/24"
}

variable "private_subnet_az_2_CIDR" {
  description = "Ingress Subnet AZ 1 CIDR"
  default = "10.0.4.0/24"
}

variable "ingress_subnet_az_1_nat_ip" {
  description = "Ingress Subnet AZ 1 CIDR"
  default = "10.0.1.11"
}

variable "ingress_subnet_az_2_nat_ip" {
  description = "Ingress Subnet AZ 1 CIDR"
  default = "10.0.2.11"
}