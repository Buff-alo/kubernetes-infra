data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2404-lts-amd64"
  project = "ubuntu-os-cloud"
}

resource "google_compute_instance" "vm" {
  count        = var.instance_count
  name         = "${var.vm_name_prefix}-${count.index + 1}"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
    }
  }

  network_interface {
    network       = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_pub_key}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      grep -q "\[gcp\]" ${var.inventory_path} || echo -e "\n[gcp]" >> ${var.inventory_path}
      
      echo "${self.name} ansible_host=${self.network_interface[0].access_config[0].nat_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${var.ssh_private_key_path}" >> ${var.inventory_path}
    EOT
  }
}
