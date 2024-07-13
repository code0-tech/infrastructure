resource "docker_volume" "pgdata" {
  name = "plane_pgdata"
}

resource "docker_volume" "redisdata" {
  name = "plane_redisdata"
}

resource "docker_volume" "uploads" {
  name = "plane_uploads"
}

resource "docker_volume" "logs_api" {
  name = "plane_logs_api"
}

resource "docker_volume" "logs_worker" {
  name = "plane_logs_worker"
}

resource "docker_volume" "logs_beat_worker" {
  name = "plane_logs_beat_worker"
}

resource "docker_volume" "logs_migrator" {
  name = "plane_logs_migrator"
}
