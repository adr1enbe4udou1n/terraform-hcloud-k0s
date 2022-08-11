variable "hcloud_token" {
  type        = string
  sensitive   = true
  description = "The token to access the Hetzner Cloud API (must have write access)"
}

variable "cluster_name" {
  type        = string
  default     = "kube"
  description = "Will be used to create the hcloud servers as a hostname prefix and main cluster name for the k0s cluster"
}

variable "cluster_user" {
  type        = string
  default     = "kube"
  description = "The default non-root user (UID=1000) that will be used to access the servers"
}

variable "cluster_fqdn" {
  type        = string
  description = "Your main domain for cluster access"
}

variable "server_location" {
  type        = string
  default     = "nbg1"
  description = "The default location to create hcloud servers"
}

variable "my_public_ssh_name" {
  type        = string
  default     = "kube"
  description = "Your public SSH key identifier for the Hetzner Cloud API"
}

variable "my_public_ssh_key" {
  type        = string
  sensitive   = true
  description = "Your public SSH key that will be used to access the servers"
}

variable "my_ip_addresses" {
  type = list(string)
  default = [
    "0.0.0.0/0",
    "::/0"
  ]
  description = "Your public IP addresses for port whitelist via the Hetzner firewall configuration"
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

variable "workers" {
  type = map(object({
    name = string
    ip   = string
  }))
  description = "List of workers"
}

variable "volumes" {
  type = map(object({
    name   = string,
    server = string,
    size   = number,
  }))
  description = "List of volumes to be attached to servers"
}

variable "lb_services" {
  type        = list(number)
  description = "List of tcp ports to be load balanced through workers"
}

variable "lb_targets" {
  type        = list(string)
  description = "List of workers to be load balanced"
}
