resource "aws_cloudwatch_log_group" "microservice" {
  name = "${var.vpc}-${var.name}"
}
