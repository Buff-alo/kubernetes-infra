terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 7.6"
    }
    oci = {
      source  = "oracle/oci"
      version = "~> 7.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
  zone    = var.gcp_zone
}

provider "oci" {
  tenancy_ocid     = var.oci_tenancy_ocid
  user_ocid        = var.oci_user_ocid
  fingerprint      = var.oci_fingerprint
  private_key_path = var.oci_private_key_path
  region           = var.oci_region
}

# --- AWS Worker ---
module "aws_worker" {
  source = "../modules/aws-instance"

  instance_count       = var.cloud_provider == "aws" ? 1 : 0
  vm_name_prefix       = "aws-kls-02-worker"
  instance_type        = "t3.micro"
  key_name             = var.aws_key_name
  inventory_path       = "${path.module}/inventory.ini"
  ssh_private_key_path = "/home/buffalo/.ssh/id_rsa"
}

# --- GCP Worker ---
module "gcp_worker" {
  source = "../modules/gcp-instance"

  instance_count       = var.cloud_provider == "gcp" ? 1 : 0
  vm_name_prefix       = "gcp-kls-02-worker"
  machine_type         = var.gcp_machine_type
  zone                 = var.gcp_zone
  ssh_user             = var.ssh_user
  ssh_pub_key          = var.ssh_pub_key
  inventory_path       = "${path.module}/inventory.ini"
  ssh_private_key_path = "/home/buffalo/.ssh/id_rsa"
}

# --- OCI Control Plane ---
module "oci_controlplane" {
  source = "../modules/oci-instance"

  # Control plane disabled for infra-02 as it joins infra-01
  instance_count       = 0
  vm_name_prefix       = "oci-kls-02-controlplane"
  compartment_ocid     = var.oci_compartment_ocid
  subnet_ocid          = var.oci_subnet_ocid
  shape                = "VM.Standard.A1.Flex"
  ocpus                = 2
  memory_in_gbs        = 12
  role                 = "controlplane"
  inventory_group_name = "oci_controlplane"
  inventory_path       = "${path.module}/inventory.ini"
  ssh_private_key_path = "/home/buffalo/.ssh/id_rsa"
}

# --- OCI Workers ---
module "oci_workers" {
  source = "../modules/oci-instance"

  instance_count       = var.cloud_provider == "oci" ? var.oci_worker_count : 0
  vm_name_prefix       = "oci-${var.vm_name}-worker-20"
  compartment_ocid     = var.oci_compartment_ocid
  subnet_ocid          = var.oci_subnet_ocid
  # Example: using A1 Flex (Arm)
  shape                = "VM.Standard.A1.Flex"
  ocpus                = 2
  memory_in_gbs        = 12
  role                 = "worker"
  inventory_group_name = "oci_workers"
  inventory_path       = "${path.module}/inventory.ini"
  ssh_private_key_path = "/home/buffalo/.ssh/id_rsa"
  boot_volume_size_in_gbs = 100
}
