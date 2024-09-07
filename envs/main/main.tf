terraform {
  backend "http" {}

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.41.0"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "17.3.1"
    }
    github = {
      source  = "integrations/github"
      version = "6.2.3"
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

provider "github" {
  owner = "code0-tech"
  app_auth {
    id = "832219"
    installation_id = "47451228"
    pem_file = var.github_app_key
  }
}

module "domain" {
  source = "../../system/domain"
  cloudflare_account_id = var.cloudflare_account_id
  cloudflare_api_token = var.cloudflare_api_token
}

module "github" {
  source = "../../system/github"
}
