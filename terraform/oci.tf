# Get Availability Domains
data "oci_identity_availability_domains" "ads" {
  count          = var.cloud_provider == "oci" ? 1 : 0
  compartment_id = var.oci_compartment_ocid
}

# Get Ubuntu Image for Arm-based instances (VM.Standard.A1.Flex)
data "oci_core_images" "ubuntu_arm" {
  count                    = var.cloud_provider == "oci" ? 1 : 0
  compartment_id           = var.oci_compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = "VM.Standard.A1.Flex" # Filter for Arm-compatible images
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# Get Ubuntu Image for AMD-based instances (VM.Standard.E2.1.Micro)
data "oci_core_images" "ubuntu_amd" {
  count                    = var.cloud_provider == "oci" ? 1 : 0
  compartment_id           = var.oci_compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = "VM.Standard.E2.1.Micro" # Filter for AMD-compatible images
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

locals {
  oci_shape_config = {
    "VM.Standard.A1.Flex" = [
      { ocpus = 1, memory_in_gbs = 6 },
      { ocpus = 2, memory_in_gbs = 12 }
    ]
    "VM.Standard.E2.1.Micro" = [
      { ocpus = 1, memory_in_gbs = 1 }
    ]
  }
}

# Control Plane (VM.Standard.A1.Flex, Arm-based)
resource "oci_core_instance" "controlplane" {
  count               = var.cloud_provider == "oci" ? 1 : 0
  availability_domain = data.oci_identity_availability_domains.ads[0].availability_domains[0].name
  compartment_id      = var.oci_compartment_ocid
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = local.oci_shape_config["VM.Standard.A1.Flex"][0].ocpus
    memory_in_gbs = local.oci_shape_config["VM.Standard.A1.Flex"][0].memory_in_gbs
  }

  display_name = "oci-${var.vm_name}-controlplane-${count.index + 1}"

  create_vnic_details {
    subnet_id        = var.oci_subnet_ocid
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
  }

  source_details {
    source_type = "image"
    source_id   = try(data.oci_core_images.ubuntu_arm[0].images[0].id, null)
  }

  freeform_tags = {
    Role = "controlplane"
  }

  provisioner "local-exec" {
    command = <<-EOT
      INVENTORY_PATH="${path.module}/inventory.ini"
      HOST_LINE="${self.display_name} ansible_host=${self.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/buffalo/.ssh/id_rsa"
      
      # 1. Echo a blank line first
      echo "" >> $INVENTORY_PATH

      # 2. Check if [oci_controlplane] header exists; if not, add it
      grep -q "\[oci_controlplane\]" $INVENTORY_PATH || echo "[oci_controlplane]" >> $INVENTORY_PATH
      
      # 3. Use SED to find the header and INSERT the host line immediately AFTER it.
      #    We must escape the backslash in the HCL template.
      sed -i "/\[oci_controlplane\]/a\\$HOST_LINE" $INVENTORY_PATH
    EOT
  }
}

# Worker Nodes
resource "oci_core_instance" "workers" {
  count               = var.cloud_provider == "oci" ? var.oci_worker_count : 0
  availability_domain = data.oci_identity_availability_domains.ads[0].availability_domains[0].name
  compartment_id      = var.oci_compartment_ocid

  # Define shapes for each worker node
  shape = count.index == 0 ? "VM.Standard.A1.Flex" : count.index == 1 ? "VM.Standard.A1.Flex" : "VM.Standard.E2.1.Micro"

  shape_config {
    ocpus         = count.index == 0 ? local.oci_shape_config["VM.Standard.A1.Flex"][1].ocpus : count.index == 1 ? local.oci_shape_config["VM.Standard.A1.Flex"][0].ocpus : local.oci_shape_config["VM.Standard.E2.1.Micro"][0].ocpus
    memory_in_gbs = count.index == 0 ? local.oci_shape_config["VM.Standard.A1.Flex"][1].memory_in_gbs : count.index == 1 ? local.oci_shape_config["VM.Standard.A1.Flex"][0].memory_in_gbs : local.oci_shape_config["VM.Standard.E2.1.Micro"][0].memory_in_gbs
  }

  display_name = "oci-${var.vm_name}-worker-${count.index + 1}"

  create_vnic_details {
    subnet_id        = var.oci_subnet_ocid
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
  }

  source_details {
    source_type = "image"
    source_id   = count.index < 2 ? try(data.oci_core_images.ubuntu_arm[0].images[0].id, null) : try(data.oci_core_images.ubuntu_amd[0].images[0].id, null)
  }

  freeform_tags = {
    Role = "worker"
  }

  provisioner "local-exec" {
    command = <<-EOT
      INVENTORY_PATH="${path.module}/inventory.ini"
      HOST_LINE="${self.display_name} ansible_host=${self.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/buffalo/.ssh/id_rsa"

      # 1. Echo a blank line first
      echo "" >> $INVENTORY_PATH
      
      # 2. Check if [oci_workers] header exists; if not, add it
      grep -q "\[oci_workers\]" $INVENTORY_PATH || echo "[oci_workers]" >> $INVENTORY_PATH
      
      # 3. Use SED to find the header and INSERT the host line immediately AFTER it.
      sed -i "/\[oci_workers\]/a\\$HOST_LINE" $INVENTORY_PATH
    EOT
  }
}