output "project_id" {
  value = google_project.x.project_id
}

output "project_name" {
  value = google_project.x.name
}

output "project_number" {
  value = google_project.x.number
}

output "org_id" {
  value = google_project.x.org_id
}

output "project_owner" {
  value = var.admin_user
}

output "region" {
  value = var.region
}

output "zone" {
  value = var.zone
}