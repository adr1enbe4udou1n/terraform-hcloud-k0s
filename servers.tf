resource "hcloud_server" "controller-01" {
  name        = "${var.prefix_name}-controller-01"
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
    sudo_user                  = var.sudo_user
    public_ssh_key             = var.my_public_ssh_key
    prefix_name                = var.prefix_name
    cluster_domain             = var.my_cluster_domain
    minion_id                  = "controller-01"
    controller_ssh_key_name    = var.controller_ssh_key_name
    controller_private_ssh_key = base64encode(var.controller_private_ssh_key)
    controller_public_ssh_key  = var.controller_public_ssh_key
    k0sctl_file_content = base64encode(
      templatefile("k0sctl.tftpl", {
        prefix_name          = var.prefix_name
        controller_ip        = "10.0.0.2"
        cluster_domain       = var.my_cluster_domain
        sudo_user            = var.sudo_user
        ssh_port             = "2222"
        private_ssh_key_path = "~/.ssh/${var.controller_ssh_key_name}"
        private_interface    = "ens10"
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
  name        = "${var.prefix_name}-worker-01"
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
    sudo_user                 = var.sudo_user
    public_ssh_key            = var.my_public_ssh_key
    prefix_name               = var.prefix_name
    cluster_domain            = var.my_cluster_domain
    minion_id                 = "worker-01"
    controller_public_ssh_key = var.controller_public_ssh_key
  })
}

resource "hcloud_server" "worker-02" {
  name        = "${var.prefix_name}-worker-02"
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
    sudo_user                 = var.sudo_user
    public_ssh_key            = var.my_public_ssh_key
    prefix_name               = var.prefix_name
    cluster_domain            = var.my_cluster_domain
    minion_id                 = "worker-02"
    controller_public_ssh_key = var.controller_public_ssh_key
  })
}

resource "hcloud_server" "data-01" {
  name        = "${var.prefix_name}-data-01"
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
    sudo_user                 = var.sudo_user
    public_ssh_key            = var.my_public_ssh_key
    prefix_name               = var.prefix_name
    cluster_domain            = var.my_cluster_domain
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
