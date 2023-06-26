# Copyright (c) HashiCorp, Inc.

data "google_client_config" "default" {
}

data "tfe_organization" "tfc_org" {
  name = var.tfc_org_name
}

resource "tfe_project" "tfc_project" {
  organization = data.tfe_organization.tfc_org.name
  name         = var.tfc_project_name
}

resource "tfe_workspace" "tfc_workspace" {
  name           = var.tfc_workspace_name
  organization   = data.tfe_organization.tfc_org.name
  project_id     = tfe_project.tfc_project.id
  agent_pool_id  = tfe_agent_pool.tfc_agent_pool.id
  execution_mode = "agent"
}

resource "tfe_agent_pool" "tfc_agent_pool" {
  name         = var.tfc_agent_pool_name
  organization = data.tfe_organization.tfc_org.name
}

resource "tfe_agent_token" "tfc_agent_token" {
  agent_pool_id = tfe_agent_pool.tfc_agent_pool.id
  description   = var.tfc_agent_pool_token
}

# module "tfc-agent-gke" {
#   source          = "../../modules/tfc-agent-gke"
#   create_network  = true
#   project_id      = var.project_id
#   tfc_agent_token = tfe_agent_token.tfc_agent_token.token
# }

module "tfc-agent-gke" {
  source          = "../../modules/tfc-agent-gke"
  create_network  = true
  network_name    = "tfc-gke-network"
  subnet_name     = "tfc-gke-subnet"
  project_id      = var.project_id
  tfc_agent_token = tfe_agent_token.tfc_agent_token.token
}
