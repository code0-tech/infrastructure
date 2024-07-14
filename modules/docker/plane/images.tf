resource "docker_image" "plane_frontend" {
  name = "makeplane/plane-frontend:v0.22-dev"
}

resource "docker_image" "plane_space" {
  name = "makeplane/plane-space:v0.22-dev"
}

resource "docker_image" "plane_admin" {
  name = "makeplane/plane-admin:v0.22-dev"
}

resource "docker_image" "plane_backend" {
  name = "makeplane/plane-backend:v0.22-dev"
}

resource "docker_image" "plane_proxy" {
  name = "makeplane/plane-proxy:v0.22-dev"
}

resource "docker_image" "postgres" {
  name = "postgres:15.7-alpine"
}

resource "docker_image" "valkey" {
  name = "valkey/valkey:7.2.5-alpine"
}

resource "docker_image" "minio" {
  name = "minio/minio:RELEASE.2024-07-10T18-41-49Z"
}
