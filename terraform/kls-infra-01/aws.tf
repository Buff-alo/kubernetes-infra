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
  count         = var.cloud_provider == "aws" ? 1 : 0
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = var.aws_key_name

  tags = {
    Name = "aws-${var.vm_name}-worker-${count.index + 1}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      grep -q "\[aws\]" ${path.module}/inventory.ini || echo -e "\n[aws]" >> ${path.module}/inventory.ini
      
      echo "${self.tags.Name} ansible_host=${self.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/buffalo/.ssh/id_rsa" >> ${path.module}/inventory.ini
    EOT
  }
}



