data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "vm" {
  count         = var.instance_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = "${var.vm_name_prefix}-${count.index + 1}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      grep -q "\[aws\]" ${var.inventory_path} || echo -e "\n[aws]" >> ${var.inventory_path}
      
      echo "${self.tags.Name} ansible_host=${self.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${var.ssh_private_key_path}" >> ${var.inventory_path}
    EOT
  }
}
