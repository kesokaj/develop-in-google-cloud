output "gke_endpoint" {
  value = google_container_cluster.x.endpoint
}

output "gke_name" {
  value = google_container_cluster.x.name
}

output "sql_name" {
  value = google_sql_database_instance.x.name
}

output "sql_root_password" {
  value = nonsensitive(google_sql_database_instance.x.root_password)
  sensitive = true
}

output "sql_connection_name" {
  value = google_sql_database_instance.x.connection_name
}

output "sql_private_ip" {
  value = google_sql_database_instance.x.private_ip_address
}

output "sql_user" {
  value = google_sql_user.x.name
}

output "sql_user_password" {
  value = nonsensitive(google_sql_user.x.password)
  sensitive = true
}

output "sql_database" {
  value = google_sql_database.x.name
}

output "reserved_ip_name" {
  value = google_compute_global_address.x.name
}

output "reserved_ip" {
  value = google_compute_global_address.x.address
}

output "gke_svc_email" {
  value = google_service_account.gke.email
}

output "gke_svc_name" {
  value = google_service_account.gke.name
}

output "frontend_source_repo" {
  value = google_sourcerepo_repository.frontend.url
}

output "backend_source_repo" {
  value = google_sourcerepo_repository.backend.url
}

output "PROJECT_ID" {
  value = data.terraform_remote_state.common.outputs.project_id
}

output "pubsub_topic" {
  value = google_pubsub_topic.x.name
}

output "pubsub_subscription" {
  value = google_pubsub_subscription.x.name
}