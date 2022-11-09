resource "consul_config_entry" "app_service_defaults" {
  name = "app"
  kind = "service-defaults"

  config_json = jsonencode({
    Kind     = "service-defaults"
    Protocol = "http"
    Protocol = "http"
  })
}

resource "consul_config_entry" "app_service_resolver" {
  name = "app"
  kind = "service-resolver"

  config_json = jsonencode({
    Kind = "service-resolver"
    Name = "app"
    DefaultSubset = "blue"
    Subsets = {
      blue = {
        Filter = "blue in Service.Tags"
      }
      green = {
        Filter = "green in Service.Tags"
      }
    }
  })
}

resource "vault_mount" "kv_secrets_engine" {
  path = "secret/"
  type = "kv-v2"
}

resource "vault_generic_secret" "docker_credentials" {
  path      = "secret/docker"
  data_json = <<EOT
{
  "username":   "${var.docker_username}",
  "password": "${var.docker_password}"
}
EOT
}

resource "waypoint_project" "hashitalks_deploy_blue_green_project" {
  project_name           = "hashitalks-deploy-blue-green"
  remote_runners_enabled = true

  data_source_git {
    git_url = "https://github.com/paladin-devops/hashitalks-deploy-blue-green"
    git_ref = "mvp"
  }
}