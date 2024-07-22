terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.37.0"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "17.2.0"
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
  source = "../../modules/gitlab/pages_domain"

  cloudflare_domain_name = "docs"
  cloudflare_zone_id = data.cloudflare_zone.main_domain.id
  gitlab_project_path = "code0-tech/development/telescopium"
  gitlab_unique_pages_url = "docs-code0-tech-c91f18c0d2259c041bf05138b194e6bb082059fe38eff2e.gitlab.io"
}

module "landing_page_pages" {
  source = "../../modules/gitlab/pages_domain"

  cloudflare_domain_name = "@"
  cloudflare_zone_id = data.cloudflare_zone.main_domain.id
  gitlab_project_path = "code0-tech/development/landing-page"
  gitlab_unique_pages_url = "landing-page-code0-tech-development-b2dc2848e053fa1893b1dfbb1ba.gitlab.io"
}

resource "cloudflare_record" "github_verification" {
  name    = "_github-challenge-code0-tech-org"
  type    = "TXT"
  zone_id = data.cloudflare_zone.main_domain.id
  value   = "e3447326f4"
  comment = "Managed by Terraform"
}

resource "cloudflare_record" "strato_spf" {
  name    = "@"
  type    = "TXT"
  zone_id = data.cloudflare_zone.main_domain.id
  value   = "v=spf1 redirect=smtp.strato.de"
  comment = "Managed by Terraform"
}

resource "cloudflare_record" "strato_dkim" {
  name    = "strato-dkim-0002._domainkey"
  type    = "CNAME"
  zone_id = data.cloudflare_zone.main_domain.id
  value   = "strato-dkim-0002._domainkey.strato.de"
  comment = "Managed by Terraform"
}
