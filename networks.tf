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
