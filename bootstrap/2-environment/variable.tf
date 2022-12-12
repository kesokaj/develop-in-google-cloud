data "terraform_remote_state" "common" {
  backend = "gcs"
  config = {
    bucket  = "<TERRAFORM_STATE_BUCKET>"
    prefix  = "<PROJECT_ID>/state/common"
  }
}

data "terraform_remote_state" "network" {
  backend = "gcs"
  config = {
    bucket  = "<TERRAFORM_STATE_BUCKET>"
    prefix  = "<PROJECT_ID>/state/network"
  }
}

resource "random_password" "sql_root" {
    length = 16
    special = false
}

resource "random_password" "sql_user" {
    length = 16
    special = false
}

resource "random_pet" "x" {
  length = 2
}

variable "gke_num_nodes" {
  default = 1
}

variable "gke_machine_type" {
  default = "n2-standard-4"
}

variable "master_ipv4_cidr_block" {
  default = "10.128.2.0/28"
}

variable "sql_machine_type" {
  description = "Set machine type for managed sql."
  default = "db-f1-micro"
}