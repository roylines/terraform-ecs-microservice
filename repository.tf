resource "aws_ecr_repository" "microservice" {
  name = "${local.microservice_fullname}"
}

resource "aws_ecr_lifecycle_policy" "microservice" {
  repository = "${aws_ecr_repository.microservice.name}"
  policy = "${file("ecr-lifecycle-policy.json")}"
}
