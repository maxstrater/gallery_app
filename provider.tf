terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
  backend "gcs" {
    bucket = "gallery-app-tf-state"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = "se422final"
  region  = "us-central1"
}