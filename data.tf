data "aws_vpc" "main" {
  tags = {
    Name = "${local.namespace}"  
  }
}

data "aws_subnet_ids" "main" {
  vpc_id = "${data.aws_vpc.main.id}"
}

data "aws_ecs_cluster" "main" {
  cluster_name = "${local.namespace}"
}

data "aws_route53_zone" "main" {
  name = "${var.name}.${var.environment}."
  private_zone = true
}
