variable "region_name" {
  type        = string
  default     = "us-west-2"
  description = "region where we will deploy application"
}
variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "instance type for instance"
}
variable "allowed_ssh_cidr" {
  description = "CIDR allowed for SSH"
  default     = "0.0.0.0/0"
}
variable "app_name" {
  type        = string
  default     = "terra-ansible-starter"
  description = "Name of the application"
}
variable "vpc_id" { 
  description = "Existing VPC ID" 
  type        = string
  default = "vpc-09f4ce04bc98e9123"
}
variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment must be dev, stage, or prod."
  }
}



