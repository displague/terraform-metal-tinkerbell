module "tinkerbell" {
  source = "git::https://github.com/displague/sandbox.git///deploy/terraform?ref=terraform-paths"

  metal_api_token = var.metal_api_token
  project_id      = var.project_id
  worker_count    = var.worker_count
  facility        = var.facility
  device_type     = var.device_type
  ssh_user        = var.ssh_user
}
