resource "google_project" "x" {
  name            = var.project_name
  project_id      = "${var.project_name}-${random_string.x.result}"
  billing_account = var.billing_id
}

resource "google_project_service" "x" {
  count                      = length(var.service_list)
  project                    = google_project.x.project_id
  service                    = var.service_list[count.index]
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_project_organization_policy" "x" {
  depends_on = [
    google_project_service.x
  ]
  count      = length(var.org_policy_list)
  project    = google_project.x.project_id
  constraint = var.org_policy_list[count.index]

  restore_policy {
    default = true
  }
}

resource "google_project_iam_member" "project_owner" {
  depends_on = [
    google_project.x,
    google_project_service.x
  ]
  project = google_project.x.project_id
  role    = "roles/owner"
  member  =  "user:${var.admin_user}"
}

resource "google_project_iam_member" "computer_svc_default" {
  depends_on = [
    google_project.x,
    google_project_service.x
  ]
  project = google_project.x.project_id
  role    = "roles/owner"
  member = "serviceAccount:${google_project.x.number}-compute@developer.gserviceaccount.com"
}