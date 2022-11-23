terraform {
  backend "gcs" {
    bucket = "spgo-terraform-state"
    prefix = "wtfpr-develop-in-gcp/state/anthos"
  }
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    acme = {
      source = "vancluever/acme"
    }      
  }
}

provider "acme" {
  #server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
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

data "google_client_config" "default" {
}

data "google_container_cluster" "x" {
  name = data.terraform_remote_state.environment.outputs.gke_name
  location = data.terraform_remote_state.common.outputs.region
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.x.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.x.master_auth[0].cluster_ca_certificate,
  )
}