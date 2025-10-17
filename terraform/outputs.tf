# resource "local_file" "inventory" {
#   content = <<EOT
# [aws]
# %{if length(try(aws_instance.vm, [])) > 0}
# ${join("\n", [for i in aws_instance.vm : "${i.tags.Name} ansible_host=${i.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/buffalo/.ssh/id_rsa"])}
# %{endif}

# [gcp]
# %{if length(try(google_compute_instance.vm, [])) > 0}
# ${join("\n", [for i in google_compute_instance.vm : "${i.name} ansible_host=${i.network_interface[0].access_config[0].nat_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/buffalo/.ssh/id_rsa"])}
# %{endif}

# [oci_controlplane]
# %{if length(try(oci_core_instance.controlplane, [])) > 0}
# ${join("\n", [for i in oci_core_instance.controlplane : "${i.display_name} ansible_host=${i.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/buffalo/.ssh/id_rsa"])}
# %{endif}

# [oci_workers]
# %{if length(try(oci_core_instance.workers, [])) > 0}
# ${join("\n", [for i in oci_core_instance.workers : "${i.display_name} ansible_host=${i.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/buffalo/.ssh/id_rsa"])}
# %{endif}

# [controlplane:children]
# oci_controlplane

# [workers:children]
# aws
# gcp
# oci_workers
# EOT

#   filename = "${path.module}/inventory.ini"
# }

output "oci_controlplane_ips" {
  value = try([for i in oci_core_instance.controlplane : i.public_ip], [])
}

output "oci_worker_ips" {
  value = try([for i in oci_core_instance.workers : i.public_ip], [])
}

output "gcp_public_ips" {
  value = try([for i in google_compute_instance.vm : i.network_interface[0].access_config[0].nat_ip], [])
}

output "aws_public_ips" {
  value = try([for i in aws_instance.vm : i.public_ip], [])
}
