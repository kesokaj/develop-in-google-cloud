data "terraform_remote_state" "common" {
  backend = "gcs"
  config = {
    bucket  = "spgo-terraform-state"
    prefix  = "wtfpr-develop-in-gcp/state/common"
  }
}

data "terraform_remote_state" "network" {
  backend = "gcs"
  config = {
    bucket  = "spgo-terraform-state"
    prefix  = "wtfpr-develop-in-gcp/state/network"
  }
}

data "terraform_remote_state" "environment" {
  backend = "gcs"
  config = {
    bucket  = "spgo-terraform-state"
    prefix  = "wtfpr-develop-in-gcp/state/environment"
  }
}

variable "loopia_user" {
  default = "developingcp@loopiaapi"
}

variable "loopia_pw" {
  default = "die0soongoangae5eewo3volooGhuoze"
}

variable "loopia_dns" {
  default = "spgo.se"
}