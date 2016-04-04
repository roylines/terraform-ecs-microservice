resource "aws_iam_role" "server_role" {
    name = "${var.vpc}-${var.name}-server-role"
    assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "server_policy" {
  name = "${var.vpc}-${var.name}-server-role-policy"
  role     = "${aws_iam_role.server_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_security_group" "microservice_elb" {
  name = "${var.vpc}-${var.name}-elb"
  description = "security group used by elb for api gateway"
  vpc_id = "${var.vpc_id}" 
  ingress {
      from_port = 80 
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
      from_port = "${var.port}"
      to_port = "${var.port}"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "${var.vpc}-${var.name}-elb"
  }
}

resource "aws_elb" "microservice" {
  name = "${var.vpc}-${var.name}"
  subnets = ["${split(",", var.subnets)}"]
  security_groups = ["${aws_security_group.microservice_elb.id}"]

  listener {
    instance_port = "${var.port}" 
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  internal = "${var.internal}"
  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 400
  
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:${var.port}/"
    interval = 30
  }
  tags {
    Name = "${var.vpc}-${var.name}"
  }
}

resource "aws_ecs_task_definition" "microservice" {
  family = "${var.vpc}-${var.name}"
  container_definitions = <<EOF
[
  {
    "name": "${var.vpc}-${var.name}",
    "image": "${var.image}",
    "cpu": 10,
    "memory": 50,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": ${var.port} 
      }
    ]
  }
]
EOF
}

resource "aws_ecs_service" "microservice" {
  name = "${var.vpc}-${var.name}"
  cluster = "${var.cluster_id}"
  task_definition = "${aws_ecs_task_definition.microservice.arn}"
  desired_count = "${var.desired_count}"
  iam_role = "${aws_iam_role.server_role.arn}"
  depends_on = ["aws_iam_role_policy.server_policy"]

  load_balancer {
    elb_name = "${aws_elb.microservice.id}"
    container_name = "${var.vpc}-${var.name}"
    container_port = 80
  }
}

resource "aws_route53_record" "microservice" {
  zone_id = "${var.private_zone_id}"
  name = "${var.name}" 
  type = "A"

  alias {
    name = "${aws_elb.microservice.dns_name}"
    zone_id = "${aws_elb.microservice.zone_id}"
    evaluate_target_health = "false" /* not allowed in private zones */
  }
}
