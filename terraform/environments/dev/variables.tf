variable "node_count" {
  type = number
}

variable "vm_size" {
  type = string
}

variable "pod_cidr" {
  type = string
}

variable "service_cidr" {
  type = string
}

variable "dns_service_ip" {
  type = string
}

variable "location" {
  description = "Azure region for Aegis infrastructure"
  type        = string
  default     = "swedencentral"
}