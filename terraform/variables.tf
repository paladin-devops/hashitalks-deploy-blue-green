variable "docker_username" {
  type      = string
  sensitive = true
}

variable "docker_password" {
  type      = string
  sensitive = true
}

variable "waypoint_address" {
  type = string
}

variable "waypoint_token" {
  type      = string
  sensitive = true
}