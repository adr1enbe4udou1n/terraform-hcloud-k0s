resource "hcloud_server" "controller-01" {
  name        = "${var.cluster_name}-controller-01"
  image       = "ubuntu-22.04"
  server_type = "cx21"
  location    = var.server_location
  ssh_keys = [
    var.my_public_ssh_name
  ]
  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.0.2"
  }
  firewall_ids = [
    hcloud_firewall.firewall-public.id,
  ]
  depends_on = [
    hcloud_network_subnet.network-subnet
  ]
  user_data = templatefile("init_controller.tftpl", {
    cluster_name               = var.cluster_name
    cluster_user               = var.cluster_user
    cluster_fqdn               = var.cluster_fqdn
    public_ssh_key             = var.my_public_ssh_key
    minion_id                  = "controller-01"
    workers                    = var.workers
    controller_private_ssh_key = base64encode(var.controller_private_ssh_key)
    controller_public_ssh_key  = var.controller_public_ssh_key
    k0sctl_file_content = base64encode(
      templatefile("k0sctl.tftpl", {
        cluster_name         = var.cluster_name
        cluster_user         = var.cluster_user
        cluster_fqdn         = var.cluster_fqdn
        controller_ip        = "10.0.0.2"
        ssh_port             = "2222"
        private_ssh_key_path = "~/.ssh/id_cluster"
        workers              = var.workers
      })
    )
  })
}

resource "hcloud_server" "workers" {
  for_each    = { for i, worker in var.workers : i => worker }
  name        = "${var.cluster_name}-${each.value.name}"
  image       = "ubuntu-22.04"
  server_type = "cx21"
  location    = var.server_location
  ssh_keys = [
    var.my_public_ssh_name
  ]
  network {
    network_id = hcloud_network.network.id
    ip         = each.value.ip
  }
  firewall_ids = [
    hcloud_firewall.firewall-private.id
  ]
  depends_on = [
    hcloud_network_subnet.network-subnet
  ]
  user_data = templatefile("init_worker.tftpl", {
    cluster_name              = var.cluster_name
    cluster_user              = var.cluster_user
    cluster_fqdn              = var.cluster_fqdn
    public_ssh_key            = var.my_public_ssh_key
    minion_id                 = each.value.name
    controller_public_ssh_key = var.controller_public_ssh_key
  })
}

resource "hcloud_volume" "volumes" {
  for_each  = { for i, volume in var.volumes : i => volume }
  name      = each.value.name
  size      = each.value.size
  server_id = hcloud_server.workers[each.value.server_index].id
  automount = true
  format    = "ext4"
}
