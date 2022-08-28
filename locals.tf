locals {
  bastion_ip = "10.0.0.254"
  servers = flatten([
    [
      for i in range(var.controllers.server_count) : {
        name        = "controller-${format("%02d", i + 1)}"
        server_type = var.controllers.server_type
        role        = "controller"
        ip          = "10.0.0.${i + 2}"
      }
    ],
    flatten([
      for i, s in var.workers : [
        for j in range(s.server_count) : {
          name        = "${s.role}-${format("%02d", j + 1)}"
          server_type = s.server_type
          role        = s.role
          ip          = "10.0.0.${j + 10 + (i * 20)}"
        }
      ]
    ])
  ])
  main_workers            = toset([for each in local.servers : each.name if each.role == "worker"])
  cluster_private_ssh_key = file("keys/id_cluster")
  cluster_public_ssh_key  = file("keys/id_cluster.pub")
  k0sctl = templatefile("k0sctl.tftpl", {
    cluster_name         = var.cluster_name
    cluster_user         = var.cluster_user
    cluster_fqdn         = var.cluster_fqdn
    controller_ip        = local.servers[0].ip
    ssh_port             = "2222"
    private_ssh_key_path = "~/.ssh/id_cluster"
    servers              = local.servers
  })
}
