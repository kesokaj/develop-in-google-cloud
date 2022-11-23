resource "random_string" "x" {
  length = 3
  special = false
  upper = false
}

variable "billing_id" {
  type = string
}

variable "project_name" {
  description = "Choose a name of your project"
  type = string
}

variable "region" {
  description = "Choose default region for project"
  type = string
}

variable "zone" {
  description = "Choose default zone for project"
  type = string
}

variable "admin_user" {
  description = "Owner for the project"
  type = string
}

variable "org_policy_list" {
  description ="The list of policies to be reset for the project."
  type = list(string)
  default = [
    "constraints/compute.requireOsLogin",
    "constraints/compute.requireShieldedVm",
    "constraints/compute.trustedImageProjects",
    "constraints/compute.vmExternalIpAccess",
    "constraints/compute.disableInternetNetworkEndpointGroup",
    "constraints/iam.disableServiceAccountKeyCreation",
    "constraints/iam.disableServiceAccountCreation",
    "constraints/compute.disableNestedVirtualization",
    "constraints/cloudfunctions.requireVPCConnector",
    "constraints/iam.allowedPolicyMemberDomains",
    "constraints/storage.uniformBucketLevelAccess",
    "constraints/sql.restrictAuthorizedNetworks"
  ]
}

variable "service_list" {
  description ="The list of services to be enabled on the project."
  type = list(string)
  default = [
    "orgpolicy.googleapis.com",
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "networkmanagement.googleapis.com",
    "firestore.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com",
    "clouddeploy.googleapis.com",
    "certificatemanager.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "monitoring.googleapis.com",
    "stackdriver.googleapis.com",
    "cloudbuild.googleapis.com",
    "dns.googleapis.com",
    "sqladmin.googleapis.com",
    "cloudtrace.googleapis.com",
    "cloudapis.googleapis.com",
    "containerregistry.googleapis.com",
    "servicenetworking.googleapis.com",
    "bigqueryconnection.googleapis.com",
    "sourcerepo.googleapis.com"
  ]
}