terraform {
  backend "http" {}

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.26.0"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "16.9.1"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "gitlab" {
  token = var.gitlab_api_token
  base_url = "https://gitlab.com/api/v4/"
}

module "domain" {
  source = "./system/domain"
  cloudflare_account_id = var.cloudflare_account_id
  cloudflare_api_token = var.cloudflare_api_token
}
