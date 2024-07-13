terraform {
  backend "http" {}

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.37.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "docker" {
  host = "ssh://pipeline@${var.server_administration_ip}:${var.server_administration_ssh_port}"

  cert_path = ""
}

resource "docker_network" "test" {
  name = "test"
}