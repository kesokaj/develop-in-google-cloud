terraform {
  backend "gcs" {
    bucket = "spgo-terraform-state"
    prefix = "wtfpr-develop-in-gcp/state/environment"
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