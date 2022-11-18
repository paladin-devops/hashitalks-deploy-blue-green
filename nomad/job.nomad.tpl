job "${app.name}" {
  name        = "${app.name}"
  region      = "global"
  datacenters = ["dc1"]
  namespace   = "default"

  group "app" {
    network {
      port "http" {
        to = 80
        static = 80
      }
    }

    service {
      name        = "app"
      port        = "http"
      tags        = [ "blue" ]
      canary_tags = [ "green" ]
    }

    update {
      max_parallel = 1
      canary       = 1
      auto_revert  = true
      auto_promote = false
      health_check = "task_states"
    }

    task "app" {
      driver = "docker"
      config {
        image = "${artifact.image}:${artifact.tag}" // use the image from the Waypoint build & registry push
        ports = ["http"]

        // Use the auth passed in via templatefile
        auth {
          username = "${username}"
          password = "${password}"
        }
      }

      env {
        %{ for k,v in entrypoint.env ~}
        ${k} = "${v}"
        %{ endfor ~}

        // Ensure we set PORT for the URL service. This is only necessary
        // if we want the URL service to function.
        PORT = 80
      }
    } // end of task
  } // end of group
} // end of job