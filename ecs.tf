resource "aws_ecs_task_definition" "microservice" {
  family = "${var.vpc}-${var.name}-${var.version}"
  container_definitions = <<EOF
[
  {
    "name": "${var.vpc}-${var.name}-${var.version}",
    "image": "${var.image}",
    "cpu": 10,
    "memory": 50,
    "portMappings": [{
      "containerPort": 80,
      "hostPort": ${var.port} 
    }],
    "environment": [{
      "name" : "LOG_GROUP_NAME",
      "value" : "${aws_cloudwatch_log_group.microservice.name}"
    }]
  }
]
EOF
}

resource "aws_ecs_service" "microservice" {
  name = "${var.vpc}-${var.name}-${var.version}"
  cluster = "${var.cluster_id}"
  task_definition = "${aws_ecs_task_definition.microservice.arn}"
  desired_count = "${var.desired_count}"
  iam_role = "${aws_iam_role.server_role.arn}"
  depends_on = ["aws_iam_role_policy.server_policy"]

  load_balancer {
    elb_name = "${aws_elb.microservice.id}"
    container_name = "${var.vpc}-${var.name}-${var.version}"
    container_port = 80
  }
}
