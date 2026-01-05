variable "cloud_provider" {
  type    = string
  default = "oci"
}

variable "vm_name" {
  type    = string
  default = "kls"
}

# AWS
variable "aws_region" {
  default = "eu-north-1"
}
variable "aws_key_name" {
  type = string
}
variable "AWS_ACCESS_KEY_ID" {
  type = string
}
variable "AWS_SECRET_ACCESS_KEY" {
  type = string
}

# GCP
variable "gcp_project" {}
variable "gcp_region" {
  default = "us-central1"
}
variable "gcp_zone" {
  default = "us-central1-a"
}
variable "gcp_machine_type" {
  default = "f1-micro"
}
variable "ssh_user" {
  type    = string
  default = "ubuntu"
}
variable "ssh_pub_key" {
  type = string
}

# OCI
variable "oci_tenancy_ocid" {
  type = string
}
variable "oci_user_ocid" {
  type = string
}
variable "oci_fingerprint" {
  type = string
}
variable "oci_private_key_path" {
  type = string
}
variable "oci_compartment_ocid" {}
variable "oci_subnet_ocid" {}
variable "oci_region" {
  default = "eu-zurich-1"
}
variable "oci_worker_count" {
  type    = number
  default = 1
}
