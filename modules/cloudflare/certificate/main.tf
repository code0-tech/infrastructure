terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.34.0"
    }
  }
}

variable "hostname" {
  type = string
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

// the key_algorithm property is read-only
//noinspection MissingProperty
resource "tls_cert_request" "this" {
  private_key_pem = tls_private_key.this.private_key_pem

  subject {
    common_name  = ""
    organization = "Code0"
  }
}

resource "cloudflare_origin_ca_certificate" "this" {
  csr                  = tls_cert_request.this.cert_request_pem
  hostnames            = [ var.hostname ]
  request_type         = "origin-rsa"
  requested_validity   = 365
  min_days_for_renewal = 90
}

output "hostname" {
  value = var.hostname
}

output "certificate" {
  value = cloudflare_origin_ca_certificate.this.certificate
}

output "private_key" {
  value = tls_private_key.this.private_key_pem
}
