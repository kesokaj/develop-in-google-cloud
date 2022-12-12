data "terraform_remote_state" "common" {
  backend = "gcs"
  config = {
    bucket  = "<TERRAFORM_STATE_BUCKET>"
    prefix  = "<PROJECT_ID>/state/common"
  }
}

resource "random_pet" "x" {
  length = 2
}

