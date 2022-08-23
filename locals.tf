locals {
  servers = flatten([
    for role, s in var.servers : [
      for i in range(s.server_count) : {
        name        = "${role}-${format("%02d", i + 1)}"
        server_type = s.server_type
        role        = role
        ip          = "10.0.0.${i + 4}"
      }
    ]
  ])
  workers                 = toset([for each in local.servers : each.name if each.role == "worker"])
  cluster_private_ssh_key = file("keys/id_cluster")
  cluster_public_ssh_key  = file("keys/id_cluster.pub")
}
