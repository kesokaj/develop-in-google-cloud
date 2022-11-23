output "vpc" {
  value = google_compute_network.vpc.name
}

output "vpc_id" {
  value = google_compute_network.vpc.id
}

output "router" {
  value = google_compute_router.x.name
}

output "nat" {
  value = google_compute_router_nat.x.name
}

output "subnetwork_europe-north1" {
  value = google_compute_subnetwork.europe-north1.name
}

output "subnetwork_europe-west1" {
  value = google_compute_subnetwork.europe-west1.name
}

output "subnetwork_us-central1" {
  value = google_compute_subnetwork.us-central1.name
}
