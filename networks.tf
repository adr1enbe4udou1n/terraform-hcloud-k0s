resource "hcloud_network" "network" {
  name     = "network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "network_subnet" {
  network_id   = hcloud_network.network.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.0.0/24"
}

resource "hcloud_load_balancer" "lb" {
  name               = "${var.cluster_name}-lb"
  load_balancer_type = "lb11"
  location           = var.server_location
}

resource "hcloud_load_balancer_network" "lb_network" {
  load_balancer_id = hcloud_load_balancer.lb.id
  network_id       = hcloud_network.network.id
  ip               = "10.0.0.3"
}

resource "hcloud_load_balancer_service" "lb_services" {
  for_each         = { for i, port in var.lb_services : port => port }
  load_balancer_id = hcloud_load_balancer.lb.id
  protocol         = "tcp"
  listen_port      = each.value
  destination_port = each.value
  proxyprotocol    = each.value == 443
}

resource "hcloud_load_balancer_target" "lb_targets" {
  for_each         = { for i, t in local.workers : i => t }
  type             = "server"
  load_balancer_id = hcloud_load_balancer.lb.id
  server_id        = hcloud_server.servers[each.value].id
  use_private_ip   = true
}

resource "hcloud_firewall" "firewall_private" {
  name = "firewall_private"
}

resource "hcloud_firewall" "firewall_public" {
  name = "firewall_public"
  rule {
    direction  = "in"
    port       = "2222"
    protocol   = "tcp"
    source_ips = var.my_ip_addresses
  }
  rule {
    direction  = "in"
    port       = "6443"
    protocol   = "tcp"
    source_ips = var.my_ip_addresses
  }
}
