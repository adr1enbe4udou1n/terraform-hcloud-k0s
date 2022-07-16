variable "prefix_name" {
  type        = string
  description = "The prefix name of all servers hostnames"
}

variable "hcloud_token" {
  type        = string
  sensitive   = true
  description = "The token to access the Hetzner Cloud API (must have write access)"
}

variable "server_location" {
  type        = string
  description = "The default location to create hcloud servers"
}

variable "my_public_ssh_name" {
  type        = string
  description = "Your public SSH key identifier for the Hetzner Cloud API"
}

variable "my_public_ssh_key" {
  type        = string
  sensitive   = true
  description = "Your public SSH key that will be used to access the servers"
}

variable "my_ip_address" {
  type        = string
  description = "Your public IP address for port whitelist via the Hetzner Firewall configuration"
}

variable "my_cluster_domain" {
  type        = string
  description = "Your main domain for cluster installation"
}

variable "sudo_user" {
  type        = string
  description = "The non-root user that will be used to access the servers"
}

variable "controller_ssh_key_name" {
  type        = string
  description = "The filename of ssh keys for the controller server"
}

variable "controller_private_ssh_key" {
  type        = string
  sensitive   = true
  description = "The private SSH key of the controller server"
}

variable "controller_public_ssh_key" {
  type        = string
  sensitive   = true
  description = "The public key of the controller server"
}
