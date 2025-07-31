terraform {
  backend "gcs" {
    bucket  = "terrabackend"
    prefix  = "terraform/state"
  }
}