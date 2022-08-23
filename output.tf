output "servers" {
  value       = local.servers
  description = "List of servers"
}

output "cluster_ip" {
  value       = hcloud_server.servers["controller-01"].ipv4_address
  description = "Public ip address of the main control pane, link this IP to your cluster_fqdn"
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
    cluster_fqdn = var.cluster_fqdn
    servers      = local.servers
  })
}
