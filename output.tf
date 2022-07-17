output "rendered" {
  value = templatefile("ssh.config.tftpl", {
    cluster_name = var.cluster_name
    cluster_user = var.cluster_user
    cluster_fqdn = var.cluster_fqdn
  })
}
