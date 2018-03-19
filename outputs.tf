output "url" {
  value = "http://${aws_alb.microservice.dns_name}:${aws_alb_listener.microservice.port}/"
}

