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

module "docs_pages" {
  source = "../modules/gitlab/pages_domain"

  cloudflare_domain_name = "docs"
  cloudflare_zone_id = data.cloudflare_zone.main_domain.id
  gitlab_project_path = "code0-tech/telescopium"
  gitlab_unique_pages_url = "docs-code0-tech-c91f18c0d2259c041bf05138b194e6bb082059fe38eff2e.gitlab.io"
}
