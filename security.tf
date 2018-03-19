resource "aws_iam_role" "microservice" {
  name = "${aws_ecr_repository.microservice.name}"
  assume_role_policy = "${file("${path.module}/role-assume.json")}"
}

resource "aws_iam_role_policy" "microservice" {
  name = "${aws_ecr_repository.microservice.name}"
  role = "${aws_iam_role.microservice.id}"
  policy = "${file("${path.module}/role-policy.json")}"
}

resource "aws_security_group" "alb" {
  vpc_id = "${data.aws_vpc.main.id}"
  name = "${local.microservice_fullname}-alb"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}
