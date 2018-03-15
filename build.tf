resource "null_resource" "build" {
  triggers {
    name = "${aws_ecr_repository.microservice.name}"
    build_version = "${var.build_version}"
  }
  
  provisioner "local-exec" {
    command = "packer build -var 'repository=${aws_ecr_repository.microservice.repository_url}' -var 'login_server=${local.repository_server}' -var 'version=${var.build_version}' ${var.packer_file}"
  }
}
