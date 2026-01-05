# Get Availability Domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

# Image Data Sources
data "oci_core_images" "ubuntu_arm" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "oci_core_images" "ubuntu_amd" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = "VM.Standard.E2.1.Micro"
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

resource "oci_core_instance" "vm" {
  count               = var.instance_count
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  
  # Logic to alternate shapes if needed, or stick to one. For the module, let's keep it simple or allow override.
  # The original code had complex logic: index 0 (Control plane A1), index 1 (Worker A1), index 2 (Worker AMD).
  # To make this module reusable, I will use var.shape and var.ocpus/memory override.
  
  shape = var.shape

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  display_name = "${var.vm_name_prefix}${count.index + 1}"

  create_vnic_details {
    subnet_id        = var.subnet_ocid
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
  }

  source_details {
    source_type = "image"
    # Select image based on shape
    source_id   = var.shape == "VM.Standard.A1.Flex" ? try(data.oci_core_images.ubuntu_arm.images[0].id, null) : try(data.oci_core_images.ubuntu_amd.images[0].id, null)
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  freeform_tags = {
    Role = var.role
  }

  lifecycle {
    ignore_changes = [
      source_details,
      shape_config,
      metadata
    ]
  }

  provisioner "local-exec" {
    command = <<-EOT
      INVENTORY_PATH="${var.inventory_path}"
      # Adjust header based on role if needed, or pass it in.
      HEADER="[${var.inventory_group_name}]"
      HOST_LINE="${self.display_name} ansible_host=${self.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${var.ssh_private_key_path}"
      
      # 1. Echo a blank line first
      echo "" >> $INVENTORY_PATH

      # 2. Check if header exists; if not, add it
      grep -q "$HEADER" $INVENTORY_PATH || echo "$HEADER" >> $INVENTORY_PATH
      
      # 3. Use SED to find the header and INSERT the host line immediately AFTER it.
      #    We key off the plain bracket text for sed
      SED_HEADER=$(echo $HEADER | sed 's/\[/\\[/g; s/\]/\\]/g')
      sed -i "/$SED_HEADER/a\\$HOST_LINE" $INVENTORY_PATH
    EOT
  }
}
