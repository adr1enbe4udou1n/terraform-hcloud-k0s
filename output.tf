output "servers" {
  value       = local.servers
  description = "List of servers"
}

output "bastion_ip" {
  value       = hcloud_server.servers[var.bastion_server].ipv4_address
  description = "Public ip address of the bastion, link this IP to connection to your bastion server"
}

output "controller_ips" {
  value       = [for c in local.controllers : hcloud_server.servers[c].ipv4_address]
  description = "Public ip address of the controllers, link them to your cluster_fqdn"
}

output "lb_ip" {
  value       = hcloud_load_balancer.lb.ipv4
  description = "Public ip address of the load balancer, use this IP as main HTTPS entrypoint through your worker nodes"
}

output "k0sctl" {
  description = "k0sctl config file"
  value       = local.k0sctl
}

output "ssh_config" {
  description = "SSH config to access to the server"
  value = templatefile("ssh.config.tftpl", {
    cluster_name = var.cluster_name
    cluster_user = var.cluster_user
    bastion_ip   = hcloud_server.servers[var.bastion_server].ipv4_address
    servers      = local.servers
  })
}
