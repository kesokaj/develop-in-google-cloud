resource "null_resource" "set_project" {
  provisioner "local-exec" {
    command = "gcloud config set project ${data.terraform_remote_state.common.outputs.project_id}"
  }
}

resource "null_resource" "kubectl" {
  depends_on = [
    null_resource.set_project
  ]
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${data.terraform_remote_state.environment.outputs.gke_name} --region=${data.terraform_remote_state.common.outputs.region}"
  }
  provisioner "local-exec" {
    when = destroy
    command = "rm -rvf $HOME/.kube/config"
  }
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = "ostling.simon@gmail.com"
}

resource "acme_certificate" "certificate" {
  depends_on = [
    acme_registration.reg
  ]
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = var.loopia_dns
  subject_alternative_names = ["*.demo.${var.loopia_dns}"]

  dns_challenge {
    provider = "loopia"
    config = {
      LOOPIA_API_USER = var.loopia_user
      LOOPIA_API_PASSWORD = var.loopia_pw     
    }     
  } 
}

resource "kubernetes_secret_v1" "wildcard-cert" {
  metadata {
    name = "wildcard-cert"
    namespace = "gateways"
  }
  data = {
    "tls.crt" = lookup(acme_certificate.certificate, "certificate_pem")
    "tls.key" = nonsensitive(lookup(acme_certificate.certificate, "private_key_pem"))
  }
  type = "kubernetes.io/tls"
}

resource "null_resource" "gateway-crd" {
  depends_on = [
    null_resource.kubectl
  ]
  provisioner "local-exec" {
    command = "kubectl apply -k github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.5.1"
  }
  provisioner "local-exec" {
    when = destroy
    command = "kubectl delete -k github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.5.1"
  }
}

resource "kubernetes_namespace_v1" "gateways" {
  metadata {
    name = "gateways"  
  }
}

resource "null_resource" "gateways" {
  depends_on = [
    null_resource.kubectl,
    null_resource.gateway-crd,
    kubernetes_namespace_v1.gateways,
    kubernetes_secret_v1.wildcard-cert
  ]
  provisioner "local-exec" {
    command = "cat k8s/gateways/external-http.yaml | sed 's/<IP>/${data.terraform_remote_state.environment.outputs.reserved_ip_name}/' | kubectl apply -f -"
  }
  provisioner "local-exec" {
    command = "kubectl apply -f k8s/gateways/internal-http.yaml"
  }
  provisioner "local-exec" {
    when = destroy
    command = "kubectl delete -f k8s/gateways/"
  }
}

#cat k8s/gmp/frontend.yaml | sed 's/<PROJECT_ID>/wtfpr-develop-in-gcp-kuu/' | kubectl apply -f -
resource "google_service_account_iam_policy" "workloadIdentity" {
  service_account_id = "${data.terraform_remote_state.environment.outputs.gke_svc_name}"
  policy_data = "${data.google_iam_policy.workloadIdentity.policy_data}"
}

data "google_iam_policy" "workloadIdentity" {
  binding {
    role = "roles/iam.workloadIdentityUser"
    members = [
      "serviceAccount:${data.terraform_remote_state.common.outputs.project_id}.svc.id.goog[gmp-public/default]",
      "serviceAccount:${data.terraform_remote_state.common.outputs.project_id}.svc.id.goog[default/default]",
      "serviceAccount:${data.terraform_remote_state.environment.outputs.gke_svc_email}"
    ]
  }
}

resource "kubernetes_annotations" "svc_default_gmp-public" {
  api_version = "v1"
  kind        = "ServiceAccount"
  metadata {
    name = "default"
    namespace = "gmp-public"
  }
  annotations = {
    "iam.gke.io/gcp-service-account" = "${data.terraform_remote_state.environment.outputs.gke_svc_email}"
  }
}

resource "kubernetes_annotations" "svc_default_default" {
  api_version = "v1"
  kind        = "ServiceAccount"
  metadata {
    name = "default"
    namespace = "default"
  }
  annotations = {
    "iam.gke.io/gcp-service-account" = "${data.terraform_remote_state.environment.outputs.gke_svc_email}"
  }
}

resource "null_resource" "gmp" {
  depends_on = [
    null_resource.kubectl,
    null_resource.gateways,
    kubernetes_annotations.svc_default_gmp-public
  ]
  provisioner "local-exec" {
    command = "kubectl apply -f k8s/gmp/cadvisor.yaml"
  }
  provisioner "local-exec" {
    command = "kubectl apply -f k8s/gmp/kube-state-metrics.yaml"
  }
  provisioner "local-exec" {
    command = "cat k8s/gmp/frontend.yaml | sed 's/<PROJECT_ID>/${data.terraform_remote_state.common.outputs.project_id}/' | kubectl apply -f -"
  }
  provisioner "local-exec" {
    command = "kubectl apply -f k8s/gmp/frontend-httproute.yaml"
  }  
  provisioner "local-exec" {
    when = destroy
    command = "kubectl delete -f k8s/gmp"
  }
}

resource "null_resource" "grafana" {
  depends_on = [
    null_resource.kubectl,
    null_resource.gateways,
    kubernetes_annotations.svc_default_gmp-public
  ]
  provisioner "local-exec" {
    command = "kubectl apply -f k8s/grafana/"
  }
  provisioner "local-exec" {
    when = destroy
    command = "kubectl delete -f k8s/grafana/"
  }
}