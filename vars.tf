variable "hcloud_token" {
  type        = string
  sensitive   = true
  description = "The token to access the Hetzner Cloud API (must have write access)"
}

variable "server_type" {
  type        = string
  default     = "cx21"
  description = "The default type size of server"
}

variable "server_image" {
  type        = string
  default     = "ubuntu-22.04"
  description = "The default OS image to use for the servers"
}

variable "server_location" {
  type        = string
  default     = "nbg1"
  description = "The default location to create hcloud servers"
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

variable "servers" {
  type = map(object({
    server_type  = string
    server_count = number
  }))
  description = "List of all nodes type to create for K0S cluster. Each type can have a different number of instances. The k0sctl config will be updated as well. If the role is different from 'worker', this node will be tainted for preventing any scheduling from pods without proper tolerations."
}

variable "volumes" {
  type = map(object({
    server = string,
    size   = number,
  }))
  description = "List of volumes to be attached to nodes. Key must correspond to a valid worker type."
}

variable "lb_services" {
  type        = list(number)
  description = "List of tcp ports to be load balanced through workers"
}
