output "aws_public_ips" {
  value = module.aws_worker.public_ips
}

output "gcp_public_ips" {
  value = module.gcp_worker.public_ips
}

output "oci_controlplane_ips" {
  value = module.oci_controlplane.public_ips
}

output "oci_worker_ips" {
  value = module.oci_workers.public_ips
}
