terraform {
  backend "gcs" {
    bucket  = "spgo-terraform-state"
    prefix  = "wtfpr-develop-in-gcp/state/common"
  }
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
}

provider "google-beta" {
}