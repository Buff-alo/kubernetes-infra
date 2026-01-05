data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2404-lts-amd64"
  project = "ubuntu-os-cloud"
}

resource "google_compute_instance" "vm" {
  count        = var.cloud_provider == "gcp" ? 1 : 0
  name         = "gcp-${var.vm_name}-worker-${count.index + 1}"
  machine_type = var.gcp_machine_type
  zone         = var.gcp_zone

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
      grep -q "\[gcp\]" ${path.module}/inventory.ini || echo -e "\n[gcp]" >> ${path.module}/inventory.ini
      
      echo "${self.name} ansible_host=${self.network_interface[0].access_config[0].nat_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/buffalo/.ssh/id_rsa" >> ${path.module}/inventory.ini
    EOT
  }
}
