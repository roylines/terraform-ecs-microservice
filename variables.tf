variable "region" {
  description = "the region"
  default = "us-east-1"
}

variable "environment" {
  description = "the environment"
  default = "prod"
}

variable "name" {
  description = "the name of this cluster"
  default = "ecs"
}

variable "microservice_name" {
  description = "the microservice name"
  default = "dummy"
}

variable "microservice_version" {
  description = "the microservice version"
  default = "v1"
}

variable "internal" {
  description = "should the microservice be internal"
  default = false
}

variable "cpu" {
  description = "the number of cpu units to reserve"
  default = 10 
}

variable "memory" {
  description = "the number of MiB of memory to reserve"
  default = 50 
}

variable "container_port" {
  description = "the port the container listens on"
  default = 8080 
}

variable "desired_count" {
  description = "the number of containers to provision"
  default = 2
}

variable "health_check_path" {
  description = "the path for the health check"
  default = "/health"
}

variable "packer_file" {
  description = "packer json file"
  default = "packer.json"
}

variable "build_version" {
  description = "the build version, e.g. 0.0.1. This is usually set by your CI platform"
}

variable "working_dir" {
  description = "the directory in which to run packer commands"
}

locals {
  namespace = "${var.environment}-${var.name}"
  microservice_fullname = "${local.namespace}-${var.microservice_name}-${var.microservice_version}"
  repository_server = "${replace(aws_ecr_repository.microservice.repository_url, "/${local.microservice_fullname}","")}"
}

