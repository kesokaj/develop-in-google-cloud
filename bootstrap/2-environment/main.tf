resource "google_compute_global_address" "x" {
  name = "${random_pet.x.id}-gclb-ingress"
}

resource "google_service_account" "gke" {
  account_id   = "gke-svc"
  display_name = "Service Account for GKE"
}

resource "google_service_account" "deploy" {
  account_id   = "deploy-svc"
  display_name = "Service Account for Cloud Deploy"
}

resource "google_project_iam_member" "gke" {
  depends_on = [
    google_service_account.gke
  ]
  project = data.terraform_remote_state.common.outputs.project_id
  role    = "roles/owner"
  member = "serviceAccount:${google_service_account.gke.email}"
}

resource "google_project_iam_member" "deploy" {
  depends_on = [
    google_service_account.gke
  ]
  project = data.terraform_remote_state.common.outputs.project_id
  role    = "roles/owner"
  member = "serviceAccount:${google_service_account.deploy.email}"
}

resource "google_container_cluster" "x" {
  depends_on = [
    google_service_account.gke
  ]
  name                      = "${random_pet.x.id}-gke"
  location                  = data.terraform_remote_state.common.outputs.region
  network                   = data.terraform_remote_state.network.outputs.vpc
  subnetwork                = data.terraform_remote_state.network.outputs.subnetwork_europe-north1
  remove_default_node_pool  = false
  initial_node_count        = var.gke_num_nodes
  networking_mode           = "VPC_NATIVE"
  datapath_provider         = "ADVANCED_DATAPATH" #DPv2
  default_max_pods_per_node = 32
  provider                  = google-beta

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
    master_global_access_config {
      enabled = true
    }
  }

  node_config {
    disk_type = "pd-ssd"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
    machine_type = var.gke_machine_type
    service_account = google_service_account.gke.email
    gvnic {
      enabled = true
    }
  }  

  release_channel {
    channel = "RAPID"
  }

  ip_allocation_policy {
    cluster_secondary_range_name = "pods"
    services_secondary_range_name = "services"
  }

  vertical_pod_autoscaling {
    enabled = true
  }

  cluster_autoscaling {
    enabled = true
    autoscaling_profile = "OPTIMIZE_UTILIZATION"
    resource_limits {
      resource_type = "cpu"
      minimum = 1
      maximum = 8
    }
    resource_limits {
      resource_type = "memory"
      minimum = 1
      maximum = 16
    }
  }

  addons_config {
    config_connector_config {
      enabled = true
    }
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
    gcp_filestore_csi_driver_config {
      enabled = true
    }
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS","WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS","APISERVER","CONTROLLER_MANAGER","SCHEDULER"]
    managed_prometheus {
      enabled = true
    }
  }

  workload_identity_config {
    workload_pool = "${data.terraform_remote_state.common.outputs.project_id}.svc.id.goog"
  }
  
}

resource "google_sql_database_instance" "x" {
  name             = "${random_pet.x.id}-sql"
  database_version = "MYSQL_8_0"
  region           = data.terraform_remote_state.common.outputs.region
  deletion_protection = false
  root_password = random_password.sql_root.result

  settings {
    disk_autoresize = true
    disk_autoresize_limit = "500"
    tier = var.sql_machine_type
    availability_type = "REGIONAL"
    ip_configuration {
      ipv4_enabled = false
      private_network = data.terraform_remote_state.network.outputs.vpc_id
    }
    backup_configuration {
      enabled = true
      binary_log_enabled = true
    }
  }
}

resource "google_sql_user" "x" {
  depends_on = [
    google_sql_database_instance.x
  ]
  name     = "${random_pet.x.id}-sql-user"
  instance = google_sql_database_instance.x.name
  host     = "%"
  password = random_password.sql_user.result
}

resource "google_sql_database" "x" {
  depends_on = [
    google_sql_database_instance.x
  ]  
  name     = "${random_pet.x.id}-database"
  instance = google_sql_database_instance.x.name
}

resource "google_clouddeploy_delivery_pipeline" "x" {
  location = data.terraform_remote_state.common.outputs.region
  name     = "${random_pet.x.id}-pipeline"
  project  = data.terraform_remote_state.common.outputs.project_id

  serial_pipeline {
    stages {
      profiles  = []
      target_id = "${random_pet.x.id}-pipeline-target"
    }
  }
}

resource "google_clouddeploy_target" "x" {
  location = data.terraform_remote_state.common.outputs.region
  name = "${random_pet.x.id}-pipeline-target"
  project = data.terraform_remote_state.common.outputs.project_id
  require_approval = true
  provider = google-beta
  
  gke {
    cluster = google_container_cluster.x.id
    internal_ip = false
  }

  execution_configs {
    service_account = google_service_account.deploy.email
    usages = ["RENDER","DEPLOY","VERIFY"]
  }  
}

resource "google_pubsub_topic" "x" {
  name = "${random_pet.x.id}-topic"
  message_retention_duration = "86600s"
  message_storage_policy {
    allowed_persistence_regions = [
      "${data.terraform_remote_state.common.outputs.region}",
    ]
  }  
}

resource "google_project_iam_member" "bq-viewer" {
  project = "${data.terraform_remote_state.common.outputs.project_id}"
  role   = "roles/bigquery.metadataViewer"
  member = "serviceAccount:service-${data.terraform_remote_state.common.outputs.project_number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "bq-editor" {
  project = "${data.terraform_remote_state.common.outputs.project_id}"
  role   = "roles/bigquery.dataEditor"
  member = "serviceAccount:service-${data.terraform_remote_state.common.outputs.project_number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

resource "google_pubsub_subscription" "x" {
  depends_on = [
    google_bigquery_dataset.x,
    google_bigquery_table.x,
    google_project_iam_member.bq-editor
  ]
  name  = "${random_pet.x.id}-subscription"
  topic = google_pubsub_topic.x.name
  bigquery_config {
    table = "${data.terraform_remote_state.common.outputs.project_id}:${google_bigquery_table.x.dataset_id}.${google_bigquery_table.x.table_id}"
  }
}

resource "google_bigquery_dataset" "x" {
  dataset_id = "${replace(random_pet.x.id,"-","_")}_dataset"
}

resource "google_bigquery_table" "x" {
  deletion_protection = false
  table_id   = "${random_pet.x.id}-table"
  dataset_id = google_bigquery_dataset.x.dataset_id

  schema = <<EOF
[
  {
    "name": "data",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The data"
  }
]
EOF
}

resource "google_bigquery_connection" "cloud-sql" {
  depends_on = [
    google_sql_database_instance.x
  ]
  connection_id = "${random_pet.x.id}-cloud-sql"
  location      = "EU"
  friendly_name = "${random_pet.x.id}-cloud-sql"
  description   = "BigQuery to CloudSQL"
  cloud_sql {
      instance_id = google_sql_database_instance.x.connection_name
      database    = google_sql_database.x.name
      type        = "MYSQL"
      credential {
        username = google_sql_user.x.name
        password = google_sql_user.x.password
      }
  }
}

resource "google_sourcerepo_repository" "frontend" {
  name = "${random_pet.x.id}-frontend"
  project = "${data.terraform_remote_state.common.outputs.project_id}"
}

resource "google_sourcerepo_repository" "backend" {
  name = "${random_pet.x.id}-backend"
  project = "${data.terraform_remote_state.common.outputs.project_id}"
}

resource "google_cloudbuild_trigger" "frontend-trigger" {
  depends_on = [
    google_sourcerepo_repository.frontend
  ]
  name = "frontend-trigger"
  location = "${data.terraform_remote_state.common.outputs.region}"
  trigger_template {
    repo_name   = google_sourcerepo_repository.frontend.name
    tag_name = "v\\d.*"
  }
  filename = "app/frontend/cloudbuild.yaml"
}

resource "google_cloudbuild_trigger" "backend-trigger" {
  depends_on = [
    google_sourcerepo_repository.backend
  ]
  name = "backend-trigger"
  location = "${data.terraform_remote_state.common.outputs.region}"
  trigger_template {
    repo_name   = google_sourcerepo_repository.backend.name
    tag_name = "v\\d.*"
  }
  filename = "app/backend/cloudbuild.yaml"
}