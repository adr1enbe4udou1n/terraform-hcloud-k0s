output "public_ip" {
  value       = hcloud_server.controller_01.ipv4_address
  description = "Value of the public ip address of the cluster, use this IP for your new domain, aka cluster_fqdn"
}

output "ssh_config" {
  description = "SSH config to access to the server"
  value = templatefile("ssh.config.tftpl", {
    cluster_name = var.cluster_name
    cluster_user = var.cluster_user
    cluster_fqdn = var.cluster_fqdn
    servers      = var.workers
  })
}
