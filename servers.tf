terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.34.3"
    }
  }
  required_providers {
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

provider "template" {
  # Configuration options
}

variable "hcloud_token" {
  sensitive = true
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "default" {
  name       = "adrien"
  public_key = file("~/.ssh/id_ed25519.pub")
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

resource "hcloud_firewall" "firewall-services" {
  name = "firewall-services"
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
}

resource "hcloud_firewall" "firewall-ssh" {
  name = "firewall-ssh"
  rule {
    direction = "in"
    port      = "2222"
    protocol  = "tcp"
    source_ips = [
      "78.228.120.81/32"
    ]
  }
}

resource "hcloud_firewall" "firewall-controller" {
  name = "firewall-controller"
  rule {
    direction = "in"
    port      = "6443"
    protocol  = "tcp"
    source_ips = [
      "78.228.120.81/32"
    ]
  }
}

resource "hcloud_server" "kube-controller-01" {
  name        = "kube-controller-01"
  image       = "ubuntu-22.04"
  server_type = "cx11"
  location    = "nbg1"
  ssh_keys = [
    "adrien"
  ]
  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.0.2"
  }
  firewall_ids = [
    hcloud_firewall.firewall-services.id,
    hcloud_firewall.firewall-ssh.id,
    hcloud_firewall.firewall-controller.id
  ]
  depends_on = [
    hcloud_network_subnet.network-subnet
  ]
  user_data = file("user_controller.yml")
}

resource "hcloud_server" "kube-worker-01" {
  name        = "kube-worker-01"
  image       = "ubuntu-22.04"
  server_type = "cx11"
  location    = "nbg1"
  ssh_keys = [
    "adrien"
  ]
  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.0.3"
  }
  firewall_ids = [
    hcloud_firewall.firewall-ssh.id
  ]
  depends_on = [
    hcloud_network_subnet.network-subnet,
    hcloud_server.kube-controller-01
  ]
  user_data = file("user_worker.yml")
}

resource "hcloud_server" "kube-worker-02" {
  name        = "kube-worker-02"
  image       = "ubuntu-22.04"
  server_type = "cx11"
  location    = "nbg1"
  ssh_keys = [
    "adrien"
  ]
  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.0.4"
  }
  firewall_ids = [
    hcloud_firewall.firewall-ssh.id
  ]
  depends_on = [
    hcloud_network_subnet.network-subnet,
    hcloud_server.kube-controller-01
  ]
  user_data = file("user_worker.yml")
}

resource "hcloud_server" "kube-data-01" {
  name        = "kube-data-01"
  image       = "ubuntu-22.04"
  server_type = "cx11"
  location    = "nbg1"
  ssh_keys = [
    "adrien"
  ]
  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.0.5"
  }
  firewall_ids = [
    hcloud_firewall.firewall-ssh.id
  ]
  depends_on = [
    hcloud_network_subnet.network-subnet,
    hcloud_server.kube-controller-01
  ]
  user_data = file("user_worker.yml")
}

resource "hcloud_volume" "volume1" {
  name      = "volume1"
  size      = 10
  server_id = hcloud_server.kube-data-01.id
  automount = true
  format    = "ext4"
}
