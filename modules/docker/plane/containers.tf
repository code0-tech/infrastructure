resource "random_password" "db" {
  length  = 32
  special = false
}

resource "random_password" "application_secret" {
  length  = 50
  special = false
}

resource "random_password" "minio_access_key_id" {
  length  = 32
  special = false
}

resource "random_password" "minio_secret_access_key" {
  length  = 32
  special = false
}

locals {
  postgres_env = [
    "POSTGRES_USER=plane",
    "POSTGRES_PASSWORD=${random_password.db.result}",
    "POSTGRES_DB=plane",
    "POSTGRES_PORT=5432",
  ]
  minio_env = [
    "MINIO_ROOT_USER=${random_password.minio_access_key_id.result}",
    "MINIO_ROOT_PASSWORD=${random_password.minio_secret_access_key.result}",
  ]
  app_env = concat([
    ### MAIN
    "WEB_URL=https://${var.web_url}",
    "DEBUG=0",
    # "SENTRY_DSN=",
    # "SENTRY_ENVIRONMENT=",
    "CORS_ALLOWED_ORIGINS=https://${var.web_url}",

    ### GUNICORN
    "GUNICORN_WORKERS=1",

    ### DB
    "PGHOST=${docker_container.postgres.name}",
    "DATABASE_URL=postgresql://plane:${random_password.db.result}@${docker_container.postgres.name}/plane",

    ### REDIS
    "REDIS_HOST=${docker_container.valkey.name}",
    "REDIS_PORT=6379",
    "REDIS_URL=redis://${docker_container.valkey.name}:6379",

    ### APPLICATION SECRET
    "SECRET_KEY=${random_password.application_secret.result}",

    ### DATA STORE
    "USE_MINIO=1",
    "AWS_REGION=",
    "AWS_ACCESS_KEY_ID=${random_password.minio_access_key_id.result}",
    "AWS_SECRET_ACCESS_KEY=${random_password.minio_secret_access_key.result}",
    "AWS_S3_ENDPOINT_URL=http://${docker_container.minio.name}:9000",
    "AWS_S3_BUCKET_NAME=plane-uploads",

    ### ADMIN / SPACE URLS
    "ADMIN_BASE_URL=",
    "SPACE_BASE_URL=",
    "APP_BAS_URL="
  ], local.postgres_env, local.minio_env)
}

//noinspection HILUnresolvedReference
resource "docker_container" "postgres" {
  image   = docker_image.postgres.image_id
  name    = "plane_postgres"
  restart = "always"

  command = ["postgres", "-c", "max_connections=1000"]

  env = local.postgres_env

  volumes {
    volume_name    = docker_volume.pgdata.name
    container_path = "/var/lib/postgresql/data"
  }

  network_mode = "bridge"

  networks_advanced {
    name = docker_network.plane.name
  }
}

//noinspection HILUnresolvedReference
resource "docker_container" "valkey" {
  image   = docker_image.valkey.image_id
  name    = "plane_valkey"
  restart = "always"

  volumes {
    volume_name    = docker_volume.redisdata.name
    container_path = "/data"
  }

  network_mode = "bridge"

  networks_advanced {
    name = docker_network.plane.name
  }
}

//noinspection HILUnresolvedReference
resource "docker_container" "minio" {
  image   = docker_image.minio.image_id
  name    = "plane_minio"
  restart = "always"

  command = ["server", "/export", "--console-address", ":9090"]

  env = local.minio_env

  volumes {
    volume_name    = docker_volume.uploads.name
    container_path = "/export"
  }

  network_mode = "bridge"

  networks_advanced {
    name    = docker_network.plane.name
    aliases = ["plane-minio"]
  }
}

//noinspection HILUnresolvedReference
resource "docker_container" "plane_web" {
  image   = docker_image.plane_frontend.image_id
  name    = "plane_web"
  restart = "always"

  command = ["node", "web/server.js", "web"]

  env = local.app_env

  network_mode = "bridge"

  networks_advanced {
    name    = docker_network.plane.name
    aliases = ["web"]
  }
}

//noinspection HILUnresolvedReference
resource "docker_container" "plane_space" {
  image   = docker_image.plane_space.image_id
  name    = "plane_space"
  restart = "always"

  command = ["node", "space/server.js", "space"]

  env = local.app_env

  network_mode = "bridge"

  networks_advanced {
    name    = docker_network.plane.name
    aliases = ["space"]
  }
}

//noinspection HILUnresolvedReference
resource "docker_container" "plane_admin" {
  image   = docker_image.plane_admin.image_id
  name    = "plane_admin"
  restart = "always"

  command = ["node", "admin/server.js", "admin"]

  env = local.app_env

  network_mode = "bridge"

  networks_advanced {
    name    = docker_network.plane.name
    aliases = ["admin"]
  }
}

//noinspection HILUnresolvedReference
resource "docker_container" "plane_api" {
  image   = docker_image.plane_backend.image_id
  name    = "plane_api"
  restart = "always"

  command = ["./bin/docker-entrypoint-api.sh"]

  env = local.app_env

  volumes {
    volume_name    = docker_volume.logs_api.name
    container_path = "/code/plane/logs"
  }

  network_mode = "bridge"

  networks_advanced {
    name    = docker_network.plane.name
    aliases = ["api"]
  }
}

//noinspection HILUnresolvedReference
resource "docker_container" "plane_worker" {
  image   = docker_image.plane_backend.image_id
  name    = "plane_worker"
  restart = "always"

  command = ["./bin/docker-entrypoint-worker.sh"]

  env = local.app_env

  volumes {
    volume_name    = docker_volume.logs_worker.name
    container_path = "/code/plane/logs"
  }

  network_mode = "bridge"

  networks_advanced {
    name = docker_network.plane.name
  }
}

//noinspection HILUnresolvedReference
resource "docker_container" "plane_beat_worker" {
  image   = docker_image.plane_backend.image_id
  name    = "plane_beat_worker"
  restart = "always"

  command = ["./bin/docker-entrypoint-beat.sh"]

  env = local.app_env

  volumes {
    volume_name    = docker_volume.logs_beat_worker.name
    container_path = "/code/plane/logs"
  }

  network_mode = "bridge"

  networks_advanced {
    name = docker_network.plane.name
  }
}

//noinspection HILUnresolvedReference
resource "docker_container" "plane_migrator" {
  image    = docker_image.plane_backend.image_id
  name     = "plane_migrator"
  restart  = "on-failure"
  must_run = false

  command = ["./bin/docker-entrypoint-migrator.sh"]

  env = local.app_env

  volumes {
    volume_name    = docker_volume.logs_migrator.name
    container_path = "/code/plane/logs"
  }

  network_mode = "bridge"

  networks_advanced {
    name = docker_network.plane.name
  }

  lifecycle {
    replace_triggered_by = [
      docker_container.plane_admin.id,
      docker_container.plane_space.id,
      docker_container.plane_api.id,
      docker_container.plane_beat_worker.id,
      docker_container.plane_web.id,
      docker_container.plane_worker.id
    ]
  }
}

//noinspection HILUnresolvedReference
resource "docker_container" "plane_proxy" {
  image   = docker_image.plane_proxy.image_id
  name    = "plane_proxy"
  restart = "always"

  env = [
    "VIRTUAL_HOST=plane.code0.tech",
    "BUCKET_NAME=plane-uploads",
    "FILE_SIZE_LIMIT=5242880"
  ]

  network_mode = "bridge"

  networks_advanced {
    name = docker_network.plane.name
  }

  networks_advanced {
    name = var.docker_proxy_network_id
  }

  lifecycle {
    replace_triggered_by = [
      docker_container.plane_web.id,
      docker_container.plane_api.id,
      docker_container.plane_space.id,
      docker_container.plane_admin.id,
      docker_container.minio.id
    ]
  }
}
