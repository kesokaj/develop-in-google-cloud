terraform {
  backend "gcs" {
    bucket  = "<TERRAFORM_STATE_BUCKET>"
    prefix  = "<PROJECT_ID>/state/common"
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