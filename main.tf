terraform {
  backend "http" {}

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.12.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "domain" {
  source = "./domain"
  cloudflare_account_id = var.cloudflare_account_id
  cloudflare_api_token = var.cloudflare_api_token
}
