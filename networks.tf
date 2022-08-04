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

resource "hcloud_managed_certificate" "managed_cert" {
  name         = "managed_cert"
  domain_names = var.domain_names
}

resource "hcloud_load_balancer_service" "lb_service_https" {
  load_balancer_id = hcloud_load_balancer.lb.id
  protocol         = "https"
  http {
    redirect_http = true
    certificates  = [hcloud_managed_certificate.managed_cert.id]
  }
}

resource "hcloud_load_balancer_service" "lb_service_ssh" {
  load_balancer_id = hcloud_load_balancer.lb.id
  protocol         = "tcp"
  listen_port      = 22
  destination_port = 22
}

resource "hcloud_load_balancer_target" "lb_target" {
  for_each         = var.lb_targets
  type             = "server"
  load_balancer_id = hcloud_load_balancer.lb.id
  server_id        = hcloud_server.workers[each.value].id
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
