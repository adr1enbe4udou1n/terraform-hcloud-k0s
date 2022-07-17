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
        ip_addrs = [
          "10.0.0.3",
          "10.0.0.4",
          "10.0.0.5",
        ]
      })
    )
  })
}

resource "hcloud_server" "worker-01" {
  name        = "${var.cluster_name}-worker-01"
  image       = "ubuntu-22.04"
  server_type = "cx21"
  location    = var.server_location
  ssh_keys = [
    var.my_public_ssh_name
  ]
  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.0.3"
  }
  firewall_ids = [
    hcloud_firewall.firewall-private.id
  ]
  depends_on = [
    hcloud_network_subnet.network-subnet,
    hcloud_server.controller-01
  ]
  user_data = templatefile("init_worker.tftpl", {
    cluster_name              = var.cluster_name
    cluster_user              = var.cluster_user
    cluster_fqdn              = var.cluster_fqdn
    public_ssh_key            = var.my_public_ssh_key
    minion_id                 = "worker-01"
    controller_public_ssh_key = var.controller_public_ssh_key
  })
}

resource "hcloud_server" "worker-02" {
  name        = "${var.cluster_name}-worker-02"
  image       = "ubuntu-22.04"
  server_type = "cx21"
  location    = var.server_location
  ssh_keys = [
    var.my_public_ssh_name
  ]
  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.0.4"
  }
  firewall_ids = [
    hcloud_firewall.firewall-private.id
  ]
  depends_on = [
    hcloud_network_subnet.network-subnet,
    hcloud_server.controller-01
  ]
  user_data = templatefile("init_worker.tftpl", {
    cluster_name              = var.cluster_name
    cluster_user              = var.cluster_user
    cluster_fqdn              = var.cluster_fqdn
    public_ssh_key            = var.my_public_ssh_key
    minion_id                 = "worker-02"
    controller_public_ssh_key = var.controller_public_ssh_key
  })
}

resource "hcloud_server" "data-01" {
  name        = "${var.cluster_name}-data-01"
  image       = "ubuntu-22.04"
  server_type = "cx21"
  location    = var.server_location
  ssh_keys = [
    var.my_public_ssh_name
  ]
  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.0.5"
  }
  firewall_ids = [
    hcloud_firewall.firewall-private.id
  ]
  depends_on = [
    hcloud_network_subnet.network-subnet,
    hcloud_server.controller-01
  ]
  user_data = templatefile("init_worker.tftpl", {
    cluster_name              = var.cluster_name
    cluster_user              = var.cluster_user
    cluster_fqdn              = var.cluster_fqdn
    public_ssh_key            = var.my_public_ssh_key
    minion_id                 = "data-01"
    controller_public_ssh_key = var.controller_public_ssh_key
  })
}

resource "hcloud_volume" "volume1" {
  name      = "volume1"
  size      = var.volume_size
  server_id = hcloud_server.data-01.id
  automount = true
  format    = "ext4"
}
