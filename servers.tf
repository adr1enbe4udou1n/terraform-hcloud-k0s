resource "hcloud_server" "servers" {
  for_each                   = { for i, s in local.servers : s.name => s }
  name                       = "${var.cluster_name}-${each.value.name}"
  image                      = var.server_image
  location                   = var.server_location
  server_type                = each.value.server_type
  ignore_remote_firewall_ids = true
  firewall_ids = [
    hcloud_firewall.firewall_private.id
  ]
  ssh_keys = [
    var.my_public_ssh_name
  ]
  depends_on = [
    hcloud_network_subnet.network_subnet
  ]
  user_data = each.value.name == var.bastion_server ? templatefile("init_bastion.tftpl", {
    server_timezone         = var.server_timezone
    server_locale           = var.server_locale
    bastion_server          = var.bastion_server
    cluster_name            = var.cluster_name
    cluster_user            = var.cluster_user
    public_ssh_key          = var.my_public_ssh_key
    servers                 = local.servers
    cluster_private_ssh_key = base64encode(local.cluster_private_ssh_key)
    cluster_public_ssh_key  = local.cluster_public_ssh_key
    k0sctl_file_content     = base64encode(local.k0sctl)
    }) : templatefile("init_server.tftpl", {
    server_timezone        = var.server_timezone
    server_locale          = var.server_locale
    cluster_user           = var.cluster_user
    bastion_ip             = local.bastion.ip
    public_ssh_key         = var.my_public_ssh_key
    minion_id              = each.value.name
    cluster_public_ssh_key = local.cluster_public_ssh_key
  })

  lifecycle {
    ignore_changes = [
      user_data,
      ssh_keys
    ]
  }
}

resource "hcloud_server_network" "servers" {
  for_each   = { for i, s in local.servers : s.name => s }
  server_id  = hcloud_server.servers[each.value.name].id
  network_id = hcloud_network.network.id
  ip         = each.value.ip
}

resource "hcloud_volume" "volumes" {
  for_each  = { for i, v in var.volumes : v.name => v }
  name      = each.key
  size      = each.value.size
  server_id = hcloud_server.servers[each.value.server].id
  automount = true
  format    = "ext4"
}
