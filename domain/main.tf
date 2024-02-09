terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.24.0"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "16.8.1"
    }
  }
}

data "cloudflare_zone" "main_domain" {
  account_id = var.cloudflare_account_id
  name       = "code0.tech"
}

resource "cloudflare_zone_settings_override" "main" {
  zone_id = data.cloudflare_zone.main_domain.id

  settings {
    ssl = "strict"
  }
}
