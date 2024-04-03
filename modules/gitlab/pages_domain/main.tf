terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.29.0"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "16.10.0"
    }
  }
}

//noinspection MissingProperty
data "gitlab_project" "this" {
  path_with_namespace = var.gitlab_project_path
}

resource "cloudflare_record" "gitlab_pages" {
  name     = var.cloudflare_domain_name
  type     = "CNAME"
  zone_id  = var.cloudflare_zone_id
  value    = var.gitlab_unique_pages_url
  proxied  = true
  comment  = "Managed by Terraform"
}

module "certificate" {
  source = "../../cloudflare/certificate"

  hostname = cloudflare_record.gitlab_pages.hostname
}

data "cloudflare_origin_ca_root_certificate" "cloudflare_root" {
  algorithm = "rsa"
}

resource "gitlab_pages_domain" "this" {
  project = data.gitlab_project.this.id
  domain  = cloudflare_record.gitlab_pages.hostname

  key         = module.certificate.private_key
  certificate = <<-EOF
    ${module.certificate.certificate}
    ${data.cloudflare_origin_ca_root_certificate.cloudflare_root.cert_pem}
  EOF
}

//noinspection HILUnresolvedReference
resource "cloudflare_record" "gitlab_pages_verification" {
  name = "_gitlab-pages-verification-code.${var.cloudflare_domain_name}"
  type = "TXT"
  zone_id = var.cloudflare_zone_id
  value = gitlab_pages_domain.this.verification_code
  comment  = "Managed by Terraform"
}
