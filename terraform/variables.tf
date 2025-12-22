variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "rapyd-sentinel"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
