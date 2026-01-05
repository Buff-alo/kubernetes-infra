variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "compartment_ocid" {
  type = string
}

variable "subnet_ocid" {
  type = string
}

variable "vm_name_prefix" {
  description = "Prefix for the VM name"
  type        = string
  default     = "oci-node"
}

variable "shape" {
  description = "OCI Shape"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "ocpus" {
  type    = number
  default = 1
}

variable "memory_in_gbs" {
  type    = number
  default = 6
}

variable "ssh_public_key_path" {
  description = "Path to public SSH key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "boot_volume_size_in_gbs" {
  type    = number
  default = 50
}

variable "role" {
  description = "Role tag"
  type        = string
  default     = "worker"
}

variable "inventory_path" {
  description = "Path to the ansible inventory file"
  type        = string
}

variable "inventory_group_name" {
  description = "Ansible inventory group name (without brackets)"
  type        = string
  default     = "oci_workers"
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key for Ansible"
  type        = string
  default     = "~/.ssh/id_rsa"
}
