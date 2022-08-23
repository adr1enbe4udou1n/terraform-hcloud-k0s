resource "hcloud_server" "main" {
  name        = "${var.cluster_name}-main"
  image       = var.server_image
  location    = var.server_location
  server_type = var.server_type
  ssh_keys = [
    var.my_public_ssh_name
  ]
  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.0.2"
  }
  firewall_ids = [
    hcloud_firewall.firewall_public.id,
  ]
  depends_on = [
    hcloud_network_subnet.network_subnet,
    hcloud_server.servers
  ]
  user_data = templatefile("init_main.tftpl", {
    cluster_name            = var.cluster_name
    cluster_user            = var.cluster_user
    cluster_fqdn            = var.cluster_fqdn
    public_ssh_key          = var.my_public_ssh_key
    servers                 = local.servers
    cluster_private_ssh_key = base64encode(local.cluster_private_ssh_key)
    cluster_public_ssh_key  = local.cluster_public_ssh_key
    k0sctl_file_content = base64encode(
      templatefile("k0sctl.tftpl", {
        cluster_name         = var.cluster_name
        cluster_user         = var.cluster_user
        cluster_fqdn         = var.cluster_fqdn
        controller_ip        = "10.0.0.2"
        ssh_port             = "2222"
        private_ssh_key_path = "~/.ssh/id_cluster"
        servers              = local.servers
      })
    )
  })
}

resource "hcloud_server" "servers" {
  for_each    = { for i, s in local.servers : s.name => s }
  name        = "${var.cluster_name}-${each.value.name}"
  image       = var.server_image
  location    = var.server_location
  server_type = each.value.server_type
  ssh_keys = [
    var.my_public_ssh_name
  ]
  network {
    network_id = hcloud_network.network.id
    ip         = each.value.ip
  }
  firewall_ids = [
    hcloud_firewall.firewall_public.id,
  ]
  depends_on = [
    hcloud_network_subnet.network_subnet
  ]
  user_data = templatefile("init_server.tftpl", {
    cluster_name           = var.cluster_name
    cluster_user           = var.cluster_user
    cluster_fqdn           = var.cluster_fqdn
    public_ssh_key         = var.my_public_ssh_key
    minion_id              = each.value.name
    cluster_public_ssh_key = local.cluster_public_ssh_key
  })
}

resource "hcloud_volume" "volumes" {
  for_each  = var.volumes
  name      = each.key
  size      = each.value.size
  server_id = hcloud_server.servers[each.value.server].id
  automount = true
  format    = "ext4"
}
