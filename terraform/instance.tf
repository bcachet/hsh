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
        directories = [
          {
            path = "/var/home/core/.config"
            mode = 448 # 0700 in decimal
            user = {
              name = "core"
            }
            group = {
              name = "core"
            }
          },
          {
            path = "/var/home/core/.config/containers"
            mode = 448 # 0700 in decimal
            user = {
              name = "core"
            }
            group = {
              name = "core"
            }
          },
          {
            path = "/var/home/core/.config/containers/systemd"
            mode = 448 # 0700 in decimal
            user = {
              name = "core"
            }
            group = {
              name = "core"
            }
          }
        ]
        files = [
          {
            path = "/var/lib/systemd/linger/core"
            mode = 420 # 0644 in decimal
          },
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

# resource "exoscale_elastic_ip" "hsh_eip" {
#   zone = var.zone
#   address_family = "inet4"
#   reverse_dns = "host3d.org"
#   healthcheck {
#     mode         = "http"
#     port         = 80
#     uri          = "/whoami"
#     interval     = 5
#     timeout      = 3
#     strikes_ok   = 2
#     strikes_fail = 3
#   }
# }

resource "exoscale_ssh_key" "hsh" {
  name = var.ssh_key.name
  public_key = var.ssh_key.public_key
}

resource "exoscale_compute_instance" "hsh" {
  name               = "hsh"
  zone               = var.zone
  type               = "standard.medium"
  disk_size          = 100
  template_id        = data.exoscale_template.template.id
  security_group_ids = [exoscale_security_group.hsh.id]
  ssh_keys           = [exoscale_ssh_key.hsh.name]
  # elastic_ip_ids     = [exoscale_elastic_ip.hsh_eip.id]

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

resource "exoscale_security_group_rule" "hsh_traefik_http" {
  security_group_id = exoscale_security_group.hsh.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

resource "exoscale_security_group_rule" "hsh_traefik_https" {
  security_group_id = exoscale_security_group.hsh.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 443
  end_port          = 443
}
