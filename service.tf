resource "aws_alb" "microservice" {
  name = "${local.microservice_fullname}"
  internal = "${var.internal}"
  subnets = ["${data.aws_subnet_ids.main.ids}"]
  security_groups = ["${aws_security_group.alb.id}"]
}

resource "aws_alb_target_group" "microservice" {
  name = "${local.microservice_fullname}"
  port = 80 /* this is always overriden in ecs service */
  protocol = "HTTP"
  vpc_id = "${data.aws_vpc.main.id}"
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "${var.health_check_path}"
  }
  depends_on = [
    "aws_alb.microservice"
  ]
}

resource "aws_alb_listener" "microservice" {
  load_balancer_arn = "${aws_alb.microservice.arn}"
  /* TODO: make SSL */
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = "${aws_alb_target_group.microservice.arn}"
    type             = "forward"
  }
}

data "template_file" "container_definitions" {
  template = "${file("${path.module}/container_definitions.json")}"
  vars {
    name = "${local.microservice_fullname}",
    image = "${aws_ecr_repository.microservice.repository_url}:${var.build_version}", 
    cpu = "${var.cpu}",
    memory = "${var.memory}",
    containerPort = "${var.container_port}",
    hostPort = 0
  }
}

resource "aws_ecs_task_definition" "microservice" {
  family = "${local.microservice_fullname}"
  container_definitions = "${data.template_file.container_definitions.rendered}"
}

resource "aws_ecs_service" "microservice" {
  name = "${local.microservice_fullname}"
  cluster = "${data.aws_ecs_cluster.main.arn}"
  task_definition = "${aws_ecs_task_definition.microservice.arn}"
  desired_count = "${var.desired_count}"
  depends_on = ["aws_iam_role_policy.microservice"]
  iam_role = "${aws_iam_role.microservice.arn}"
  placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }
  load_balancer {
    target_group_arn = "${aws_alb_target_group.microservice.arn}"
    container_name = "${local.microservice_fullname}"
    container_port = "${var.container_port}"
  }
}
