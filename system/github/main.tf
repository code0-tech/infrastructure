terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "6.3.1"
    }
  }
}

data "github_repositories" "repositories" {
  query = "org:code0-tech"
}

module "global_labels" {
  source = "../../modules/github/global_labels"

  for_each = toset(data.github_repositories.repositories.names)
  repository = each.value
}
