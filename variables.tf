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

variable "packer_file" {
  description = "packer json file"
  default = "packer.json"
}

variable "build_version" {
  description = "the build version"
  default = "0.0.1"
}

locals {
  namespace = "${var.environment}-${var.name}"
  microservice_fullname = "${var.environment}-${var.name}-${var.microservice_name}-${var.microservice_version}"
  repository_server = "${replace(aws_ecr_repository.microservice.repository_url, "/${local.microservice_fullname}","")}"
}

/*

variable "vpc" {
  description = "the vpc name"
}

variable "vpc_id" {
  description = "the vpc id"
}

variable "region" {
  description = "the region"
}

variable "subnets" {
  description = "the subnets"
}

variable "private_zone_id" {
  description = "the r53 private zone id"
}

variable "cluster_id" {
  description = "the cluster_id"
}

variable "microservice_elb_security_group_id" {
  description = "the elb security group to use id"
}

variable "name" {
  description = "the microservice name"
}

variable "version" {
  description = "the microservice version"
  default = "v1"
}

variable "image" {
  description = "the docker container image to use"
}

variable "container_port" {
  description = "the container port"
  default = 8080
}

variable "port" {
  description = "the microservice port"
}

variable "cpu" {
  description = "the number of cpu units to reserve"
  default = 10 
}

variable "memory" {
  description = "the number of MiB of memory to reserve"
  default = 50 
}

variable "desired_count" {
  description = "the number of microservices to provision"
}

variable "internal" {
  description = "is the microservice internal only"
  default = true
}

variable "acm_certificate_arn" {
  description = "the ARN of the aws certificate manager certificate to use"
}
*/
