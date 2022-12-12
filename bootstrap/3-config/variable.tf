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

data "terraform_remote_state" "environment" {
  backend = "gcs"
  config = {
    bucket  = "<TERRAFORM_STATE_BUCKET>"
    prefix  = "<PROJECT_ID>/state/environment"
  }
}

variable "loopia_user" {
  default = "<API_USER>@loopiaapi"
}

variable "loopia_pw" {
  default = "<YOUR_LOOPIA_PW>"
}

variable "loopia_dns" {
  default = "<DNS>"
}