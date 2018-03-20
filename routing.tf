data "aws_route53_zone" "microservice" {
	name = "${var.name}.${var.environment}."
  private_zone = true
}

resource "aws_route53_record" "microservice" {
  zone_id = "${data.aws_route53_zone.microservice.zone_id}"
	name = "${var.microservice_version}.${var.microservice_name}"
  type = "A"
  alias {
    name = "${aws_alb.microservice.dns_name}"
    zone_id = "${aws_alb.microservice.zone_id}"
    evaluate_target_health = "false" /* not allowed in private zones */
  }
}
