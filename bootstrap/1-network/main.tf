
### VPC
resource "google_compute_network" "vpc" {
  project                 = data.terraform_remote_state.common.outputs.project_id
  name                    = "${random_pet.x.id}-vpc"
  auto_create_subnetworks = false
  mtu                     = 1500
  routing_mode            = "GLOBAL"
}

### Private SQL-Allocation
resource "google_compute_global_address" "x" {
  name          = "${random_pet.x.id}-sql-allocation"
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  network       = google_compute_network.vpc.id
  address       = "10.128.3.0"
  prefix_length = 24

}

resource "google_service_networking_connection" "x" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.x.name]
}


### SUB NETWORK 
resource "google_compute_subnetwork" "europe-north1" {
  name                     = "europe-north1"
  ip_cidr_range            = "10.128.0.0/23"
  region                   = "europe-north1"
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
  secondary_ip_range = [
    {
      range_name = "pods"
      ip_cidr_range = "10.128.4.0/22"
    },
    {
      range_name = "services"
      ip_cidr_range = "10.128.8.0/22"
    }
  ]   
}

resource "google_compute_subnetwork" "europe-north1-gke-proxy-only" {
  provider = google-beta

  name          = "gke-proxy-only"
  ip_cidr_range = "10.128.2.128/26"
  region        = "europe-north1"
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "europe-west1" {
  name                     = "europe-west1"
  ip_cidr_range            = "10.128.12.0/23"
  region                   = "europe-west1"
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
  secondary_ip_range = [
    {
      range_name = "pods"
      ip_cidr_range = "10.128.16.0/22"
    },
    {
      range_name = "services"
      ip_cidr_range = "10.128.20.0/22"
    }
  ]    
}

resource "google_compute_subnetwork" "us-central1" {
  name                     = "us-central1"
  ip_cidr_range            = "10.128.24.0/23"
  region                   = "us-central1"
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
  secondary_ip_range = [
    {
      range_name = "pods"
      ip_cidr_range = "10.128.28.0/22"
    },
    {
      range_name = "services"
      ip_cidr_range = "10.128.32.0/22"
    }
  ]    
}

### FIREWALL
resource "google_compute_firewall" "allow-ssh" {
  name    = "${google_compute_network.vpc.name}-allow-ssh"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["ssh"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-rdp" {
  name    = "${google_compute_network.vpc.name}-allow-rdp"
  network = google_compute_network.vpc.id
  
  allow {
    protocol = "tcp" 
    ports    = ["3389"]
  }
  
  target_tags = ["rdp"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-healthcheck" {
  name    = "${google_compute_network.vpc.name}-allow-healthcheck"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["80","443"]
  }
  
  source_ranges = ["130.211.0.0/22","35.191.0.0/16"]
}

resource "google_compute_firewall" "allow-http" {
  name    = "${google_compute_network.vpc.name}-allow-http"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  
  target_tags = ["http"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-https" {
  name    = "${google_compute_network.vpc.name}-allow-https"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  
  target_tags = ["https"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-iap" {
  name    = "${google_compute_network.vpc.name}-allow-iap"
  network = google_compute_network.vpc.id
  
  allow {
    protocol = "tcp"
    ports    = ["22","3389"]
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "allow-internal" {
  name    = "${google_compute_network.vpc.name}-allow-internal"        
  network = google_compute_network.vpc.id

  allow {
    protocol = "all"
  }
  
  source_ranges = ["10.128.0.0/16"]               
}

resource "google_compute_firewall" "allow-icmp" {
  name    = "${google_compute_network.vpc.name}-allow-icmp"
  network = google_compute_network.vpc.id
  
  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

### NAT
resource "google_compute_address" "nat_ip" {
  count  = 3
  name   = "${random_pet.x.id}-${count.index}"
  region = data.terraform_remote_state.common.outputs.region
}

resource "google_compute_router" "x" {
  name    = "${google_compute_network.vpc.name}-natgw"
  region  = data.terraform_remote_state.common.outputs.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "x" {
  name                               = "${google_compute_network.vpc.name}-nat"
  router                             = google_compute_router.x.name
  region                             = google_compute_router.x.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.nat_ip.*.self_link
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  enable_endpoint_independent_mapping = false
  enable_dynamic_port_allocation = true

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }  
}