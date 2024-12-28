terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "17.7.0"
    }
  }
}
