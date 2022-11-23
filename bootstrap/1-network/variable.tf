data "terraform_remote_state" "common" {
  backend = "gcs"
  config = {
    bucket  = "spgo-terraform-state"
    prefix  = "wtfpr-develop-in-gcp/state/common"
  }
}

resource "random_pet" "x" {
  length = 2
}

