terraform {
  backend "gcs" {
    bucket = "<TERRAFORM_STATE_BUCKET>"
    prefix = "<PROJECT_ID>/state/environment"
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
  zone    = data.terraform_remote_state.common.outputs.zone
}

provider "google-beta" {
  project = data.terraform_remote_state.common.outputs.project_id
  region  = data.terraform_remote_state.common.outputs.region
  zone    = data.terraform_remote_state.common.outputs.zone
}