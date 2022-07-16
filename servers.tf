terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.34.3"
    }
  }
}

variable "prefix_name" {
  type = string
}

variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "public_ssh_name" {
  type = string
}

variable "public_ssh_key" {
  type      = string
  sensitive = true
}

variable "my_ip_address" {
  type      = string
  sensitive = true
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "default" {
  name       = var.public_ssh_name
  public_key = var.public_ssh_key
}

resource "hcloud_network" "network" {
  name     = "network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "network-subnet" {
  network_id   = hcloud_network.network.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.0.0/24"
}

resource "hcloud_firewall" "firewall-private" {
  name = "firewall-private"
}

resource "hcloud_firewall" "firewall-public" {
  name = "firewall-public"
  rule {
    direction = "in"
    port      = "22"
    protocol  = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    port      = "80"
    protocol  = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    port      = "443"
    protocol  = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    port      = "2222"
    protocol  = "tcp"
    source_ips = [
      "${var.my_ip_address}/32"
    ]
  }
  rule {
    direction = "in"
    port      = "6443"
    protocol  = "tcp"
    source_ips = [
      "${var.my_ip_address}/32"
    ]
  }
}

resource "hcloud_server" "controller-01" {
  name        = "${var.prefix_name}-controller-01"
  image       = "ubuntu-22.04"
  server_type = "cx21"
  location    = "nbg1"
  ssh_keys = [
    var.public_ssh_name
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
  user_data = templatefile("init_controller.tpl", {
    public_ssh_key = var.public_ssh_key
    prefix_name    = var.prefix_name
    minion_id      = "controller-01"
  })
}

resource "hcloud_server" "worker-01" {
  name        = "${var.prefix_name}-worker-01"
  image       = "ubuntu-22.04"
  server_type = "cx21"
  location    = "nbg1"
  ssh_keys = [
    var.public_ssh_name
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
  user_data = templatefile("init_worker.tpl", {
    public_ssh_key = var.public_ssh_key
    prefix_name    = var.prefix_name
    minion_id      = "worker-01"
  })
}

resource "hcloud_server" "worker-02" {
  name        = "${var.prefix_name}-worker-02"
  image       = "ubuntu-22.04"
  server_type = "cx21"
  location    = "nbg1"
  ssh_keys = [
    var.public_ssh_name
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
  user_data = templatefile("init_worker.tpl", {
    public_ssh_key = var.public_ssh_key
    prefix_name    = var.prefix_name
    minion_id      = "worker-02"
  })
}

resource "hcloud_server" "data-01" {
  name        = "${var.prefix_name}-data-01"
  image       = "ubuntu-22.04"
  server_type = "cx21"
  location    = "nbg1"
  ssh_keys = [
    var.public_ssh_name
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
  user_data = templatefile("init_worker.tpl", {
    public_ssh_key = var.public_ssh_key
    prefix_name    = var.prefix_name
    minion_id      = "data-01"
  })
}

resource "hcloud_volume" "volume1" {
  name      = "volume1"
  size      = 10
  server_id = hcloud_server.data-01.id
  automount = true
  format    = "ext4"
}
