output "alb_dns_name" {
  value = "${aws_alb.microservice.dns_name}"
}

