data "exoscale_template" "template" {
  zone = var.zone
  name = var.template_name
}

data "ct_config" "hsh" {
  strict       = true
  pretty_print = true
  snippets     = []
  content = yamlencode(
    {
      variant = "fcos"
      version = "1.5.0"
      passwd = {
        users = [
          {
            name                = "core"
            ssh_authorized_keys = [var.ssh_key.public_key]
          }
        ]
      }
      storage = {
        files = [
          {
            path = "/etc/sysctl.d/20-dns-privileged-port.conf"
            contents = {
              inline = <<-EOT
              net.ipv4.ip_unprivileged_port_start=53
              EOT
            }
          },
          {
            path = "/etc/systemd/resolved.conf.d/adguard-dns.conf"
            contents = {
              inline = <<-EOT
              [Resolve]
              DNS=127.0.0.1
              DNSStubListener=no
              EOT
            }
          }
        ]
      }
    }
  )
}

resource "exoscale_compute_instance" "hsh" {
  name               = "hsh"
  zone               = var.zone
  type               = "standard.medium"
  disk_size          = 100
  template_id        = data.exoscale_template.template.id
  security_group_ids = [exoscale_security_group.hsh.id]
  ssh_keys           = [var.ssh_key.name]

  user_data = data.ct_config.hsh.rendered
}

resource "exoscale_security_group" "hsh" {
  name = "hsh"
}

resource "exoscale_security_group_rule" "hsh_ssh" {
  security_group_id = exoscale_security_group.hsh.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 22
  end_port          = 22
}

resource "exoscale_security_group_rule" "hsh_adguard_dns_tcp" {
  security_group_id = exoscale_security_group.hsh.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 53
  end_port          = 53
}

resource "exoscale_security_group_rule" "hsh_adguard_dns_udp" {
  security_group_id = exoscale_security_group.hsh.id
  type              = "INGRESS"
  protocol          = "UDP"
  cidr              = "0.0.0.0/0"
  start_port        = 53
  end_port          = 53
}

resource "exoscale_security_group_rule" "hsh_adguard_admin" {
  security_group_id = exoscale_security_group.hsh.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 5300
  end_port          = 5300
}

resource "exoscale_security_group_rule" "hsh_adguard_dns_over_http" {
  security_group_id = exoscale_security_group.hsh.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 8080
  end_port          = 8080
}
