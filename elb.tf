resource "aws_security_group" "microservice_elb" {
  name = "${var.vpc}-${var.name}-${var.version}-elb"
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
    Name = "${var.vpc}-${var.name}-${var.version}-elb"
  }
}

resource "aws_elb" "microservice" {
  name = "${var.vpc}-${var.name}-${var.version}"
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
    Name = "${var.vpc}-${var.name}-${var.version}"
  }
}

