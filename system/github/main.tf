terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "6.5.0"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "17.8.0"
    }
  }
}

data "github_repositories" "repositories" {
  query = "org:code0-tech"
}

data "github_repositories" "public_repositories" {
  query = "org:code0-tech visibility:public"
}

module "global_labels" {
  source = "../../modules/github/global_labels"

  for_each = toset(data.github_repositories.repositories.names)
  repository = each.value
}

data "gitlab_project_variable" "github_discord_webhook_url" {
  project = "code0-tech/secret-manager"
  key     = "GITHUB_DISCORD_WEBHOOK_URL"
}

resource "github_repository_webhook" "discord_webhook" {
  for_each = toset(data.github_repositories.public_repositories.names)

  repository = each.value

  events = [
    "discussion",
    "fork",
    "issues",
    "pull_request",
    "pull_request_review",
    "push",
    "release",
    "star",
    "watch"
  ]

  configuration {
    //noinspection HILUnresolvedReference
    url = data.gitlab_project_variable.github_discord_webhook_url.value
    content_type = "json"
  }
}
