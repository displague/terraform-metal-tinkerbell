provider "docker" {
  host = "ssh://root@${module.tinkerbell.provisioner_ip}"
}

resource "docker_image" "image2disk" {
  name = "quay.io/tinkerbell-actions/image2disk:v1.0.0"
}

resource "docker_image" "cexec" {
  name = "quay.io/tinkerbell-actions/cexec:v1.0.0"
}

resource "docker_image" "kexec" {
  name = "quay.io/tinkerbell-actions/kexec:v1.0.0"
}
