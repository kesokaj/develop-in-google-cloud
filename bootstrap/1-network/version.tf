terraform {
  backend "gcs" {
    bucket = "<TERRAFORM_STATE_BUCKET>"
    prefix = "<PROJECT_ID>/state/network"
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