variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "vm_name_prefix" {
  description = "Prefix for the VM name"
  type        = string
  default     = "gcp-worker"
}

variable "machine_type" {
  description = "GCP machine type"
  type        = string
  default     = "f1-micro"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "ssh_user" {
  description = "SSH user for metadata"
  type        = string
  default     = "ubuntu"
}

variable "ssh_pub_key" {
  description = "SSH public key for metadata"
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
