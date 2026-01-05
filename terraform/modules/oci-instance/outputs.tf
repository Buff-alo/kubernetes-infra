output "public_ips" {
  value = oci_core_instance.vm[*].public_ip
}
