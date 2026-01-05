variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "vm_name_prefix" {
  description = "Prefix for the VM name"
  type        = string
  default     = "aws-worker"
}

variable "instance_type" {
  description = "AWS instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "AWS key pair name"
  type        = string
}

variable "inventory_path" {
  description = "Path to the ansible inventory file"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key for Ansible"
  type        = string
  default     = "~/.ssh/id_rsa"
}
