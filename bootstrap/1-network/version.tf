terraform {
  backend "gcs" {
    bucket = "spgo-terraform-state"
    prefix = "wtfpr-develop-in-gcp/state/network"
  }
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  project = data.terraform_remote_state.common.outputs.project_id
  region  = data.terraform_remote_state.common.outputs.region
}

provider "google-beta" {
  project = data.terraform_remote_state.common.outputs.project_id
  region  = data.terraform_remote_state.common.outputs.region
}