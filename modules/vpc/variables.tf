variable "project_name"{
  type = string
  default = "python-app"
}

variable "vpc" {
  type = string
  default = "10.0.0.0/16"
  
}
variable "public_subnet_cidrs"{
  type = list(string)
  default = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type = list(string)
  default = ["10.0.10.0/24","10.0.11.0/24","10.0.12.0/24"]
}
variable "aws_azs" {
  type = list(string)
  default = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  
}
