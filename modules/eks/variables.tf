variable "project_name" {
  type        = string
  description = "Project name used for resource naming"
  default = "python-app"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs from the VPC module"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for worker nodes"
  default     = "t3.medium"
}

variable "node_min" {
  type        = number
  description = "Minimum nodes in the node group"
  default = 1
}

variable "node_desired" {
  type        = number
  description = "Desired nodes in the node group"
  default = 1
}

variable "node_max" {
  type        = number
  description = "Maximum nodes in the node group"
  default= 1
}