terraform {
    required_version = "> 1.0.10"
    required_providers {
        intersight = {
            source = "CiscoDevNet/intersight"
            version = ">=1.0.28"
        }
    }
}

provider "intersight" {
    apikey = "61fdbccf7564612d3301c805/6335bb167564612d31b983d1/6335da237564612d31ba6964"
    secretkey = var.secretkey
    endpoint = var.endpoint
}

data "intersight_organization_organization" "default" {
    name = "default"
}
# print default org moid
output "org_default_moid" {
    value = data.intersight_organization_organization.default.moid
}

module "intersight_policy_bundle" {
  source = "./tf-intersight-policy-bundle"

  # external sources
  organization    = data.intersight_organization_organization.default.id

  # every policy created will have this prefix in its name
  policy_prefix = "lab"
  description   = "Built by Andrew using Terraform"

  # Fabric Interconnect 6454 config specifics
  server_ports_6454 = [33, 34]
  port_channel_6454 = [53, 54]
  uplink_vlans_6454 = {
    "vlan-102" : 102,
    "vlan-103" : 103,
    "vlan-103" : 103,
    
  }
  native_vlans_6454 = {
    "vlan-101-Mgmt" : 101,
  }
  
  fc_port_count_6454 = 4

  imc_access_vlan    = 101
  imc_admin_password = "C1sco12345"

  ntp_servers = ["10.101.128.15"]

  dns_preferred = "10.101.128.15"
  dns_alternate = "10.101.128.16"

  ntp_timezone = "America/New_York"

  # starting values for wwnn, wwpn-a/b and mac pools (size 255)
  wwnn-block   = "20:00:00:25:B5:E1:00:00"
  wwpn-a-block = "20:00:00:25:B5:E1:A0:00"
  wwpn-b-block = "20:00:00:25:B5:E1:B0:00"
  mac-block    = "00:25:B5:E1:A0:00"
  uuid-block   = "0000-000000000000"

  tags = [
    { "key" : "Environment", "value" : "USCX_ASL_LAB" },
    { "key" : "Orchestrator", "value" : "Terraform" }
  ]
}
