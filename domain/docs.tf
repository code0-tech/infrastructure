//noinspection MissingProperty
data "gitlab_project" "telescopium" {
  path_with_namespace = "code0-tech/telescopium"
}

resource "cloudflare_record" "docs_gitlab_pages" {
  name     = "docs"
  type     = "CNAME"
  zone_id  = data.cloudflare_zone.main_domain.id
  value    = "docs-code0-tech-c91f18c0d2259c041bf05138b194e6bb082059fe38eff2e.gitlab.io"
  proxied  = true
  comment  = "Managed by Terraform"
}

module "pages_certificate" {
  source = "../modules/cloudflare/certificate"

  hostname = cloudflare_record.docs_gitlab_pages.hostname
}

data "cloudflare_origin_ca_root_certificate" "cloudflare_root" {
  algorithm = "rsa"
}

resource "gitlab_pages_domain" "docs" {
  project = data.gitlab_project.telescopium.id
  domain  = cloudflare_record.docs_gitlab_pages.hostname

  key         = module.pages_certificate.private_key
  certificate = <<-EOF
    ${module.pages_certificate.certificate}
    ${data.cloudflare_origin_ca_root_certificate.cloudflare_root.cert_pem}
  EOF
}

//noinspection HILUnresolvedReference
resource "cloudflare_record" "docs_gitlab_pages_verification" {
  name = "_gitlab-pages-verification-code.docs"
  type = "TXT"
  zone_id = data.cloudflare_zone.main_domain.id
  value = gitlab_pages_domain.docs.verification_code
  comment  = "Managed by Terraform"
}
