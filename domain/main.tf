terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.24.0"
    }
  }
}

data "cloudflare_zone" "main_domain" {
  account_id = var.cloudflare_account_id
  name       = "code0.tech"
}
