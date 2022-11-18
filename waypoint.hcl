project = "hashitalks-deploy-blue-green"

pipeline "build-and-blue-green-deployment" {
  step "build" {
    use "build" {
      disable_push = false
    }
  }

  step "blue-green-deployment-pipeline" {
    use "pipeline" {
      project = "hashitalks-deploy-blue-green"
      name    = "blue-green-deployment"
    }
  }
}

pipeline "blue-green-deployment" {
  step "deploy" {
    use "deploy" {}
  }

  step "split-traffic-to-green" {
    image_url = "consul"

    use "exec" {
      command = "sh"
      args = [
        "-c",
        "curl -o green-splitter.consul.hcl https://raw.githubusercontent.com/paladin-devops/hashitalks-deploy-blue-green/main/consul/green-splitter.consul.hcl && consul config write -http-addr=${var.consul_address} green-splitter.consul.hcl",
      ]
    }
  }
}

pipeline "promotion-and-normalize-traffic" {
  step "normalize-traffic" {
    image_url = "consul"

    use "exec" {
      command = "sh"
      args = [
        "-c",
        "curl -o normalize.consul.hcl https://raw.githubusercontent.com/paladin-devops/hashitalks-deploy-blue-green/main/consul/normalize.consul.hcl && consul config write -http-addr=${var.consul_address} normalize.consul.hcl",
      ]
    }
  }

  step "promote-deployment" {
    use "release" {
      prune = false
    }
  }
}

app "my-app" {
  build {
    use "pack" {}

    registry {
      use "docker" {
        image = "devopspaladin/hashitalks-deploy"
        tag   = "latest"
        auth {
          // Credentials are supplied here for authentication to push to a registry.
          username = var.username
          password = var.password
        }
      }
    }
  }

  config {
    env = {
      // The application being deployed expects these environment variables in order
      // to connect to a database, and they're being supplied via input variables.
      "USERNAME" = var.postgres_username
      "PASSWORD" = var.postgres_password
      "HOST"     = var.postgres_ip
      "PORT"     = var.postgres_port
      "DBNAME"   = var.postgres_dbname
    }
  }

  deploy {
    use "nomad-jobspec" {
      jobspec = templatefile("${path.app}/nomad/job.nomad.tpl", {
        // The registry username and password are passed to the Nomad job template
        // so that the Nomad client can pull the image from the Docker registry.
        username = var.username
        password = var.password
      })
    }
  }

  release {
    use "nomad-jobspec-canary" {
      // The task group containing the app whose canary deployment will be
      // promoted is named "app", so it is explicitly specified here.
      groups = ["app"]

      // If something is wrong with the canary deployment, the input var here allows
      // the operator to fail the deployment so it is rolled back to the previous
      // version. By default, it will be promoted.
      fail_deployment = var.fail_deployment
    }
  }
}

// Vault config sourcing is not required in order to use these variables. They
// can be overridden with with -var flag or a -var-file.
variable "username" {
  type = string
  default = dynamic("vault", {
    "path" = "kv/data/docker"
    "key"  = "/data/username"
  })
  sensitive = true
}

variable "password" {
  type = string
  default = dynamic("vault", {
    path = "kv/data/docker"
    key  = "/data/password"
  })
  sensitive = true
}

variable "consul_address" {
  type = string
}

// Vault config sourcing is not required in order to use these variables. They
// can be overridden with with -var flag or a -var-file.
variable "postgres_username" {
  type      = string
  sensitive = true
  default = dynamic("vault", {
    path = "database/creds/readonly"
    key  = "username"
  })
}

variable "postgres_username" {
  type      = string
  sensitive = true
  default = dynamic("vault", {
    path = "database/creds/readonly"
    key  = "password"
  })
}

variable "postgres_ip" {
  type = string
}

variable "postgres_port" {
  type = number
}

variable "postgres_dbname" {
  type    = string
  default = "postgres"
}

variable "fail_deployment" {
  type = bool
  default = false
}