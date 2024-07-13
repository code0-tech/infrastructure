terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.37.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

data "cloudflare_zone" "main_domain" {
  account_id = var.cloudflare_account_id
  name       = "code0.tech"
}

module "proxy" {
  source = "../../modules/docker/proxy"

  certificate_hostnames = [
    "plane.code0.tech",
  ]
}

module "plane" {
  source = "../../modules/docker/plane"

  web_url                 = "plane.code0.tech"
  docker_proxy_network_id = module.proxy.docker_proxy_network_id
}

resource "cloudflare_record" "server_ip" {
  name    = "server_administration"
  type    = "A"
  zone_id = data.cloudflare_zone.main_domain.id
  value   = var.server_administration_ip
  proxied = true

  comment = "Managed by Terraform"
}

resource "cloudflare_record" "server_cname" {
  for_each = toset([
    "plane"
  ])

  name    = each.value
  type    = "CNAME"
  zone_id = data.cloudflare_zone.main_domain.id
  value   = cloudflare_record.server_ip.hostname
  proxied = true

  comment = "Managed by Terraform"
}
