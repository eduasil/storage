terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "almeidacorp"

    workspaces {
      name = "storage"
    }
  }
}