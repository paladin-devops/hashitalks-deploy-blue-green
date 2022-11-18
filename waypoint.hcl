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
  config {
    env = {
      PALADIN = dynamic("vault", {
        path = "/secret/data/test"
        key  = "/data/test"
      })
    }
  }

  build {
    use "pack" {}

    registry {
      use "docker" {
        image = "devopspaladin/hashitalks-deploy"
        tag   = "latest"
        auth {
          username = var.username
          password = var.password
        }
      }
    }
  }

  deploy {
    use "nomad-jobspec" {
      jobspec = templatefile("${path.app}/nomad/job.nomad.tpl", {
        username = var.username
        password = var.password
      })
    }
  }

  release {
    use "nomad-jobspec-canary" {
      groups = ["app"]
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
