# This file creates the following pools:
#    - IP pool for IMC Access
#    - MAC pool for vNICs
#    - WWNN, WWPN-A and WWPN-B FC pools

# Create a sequential IP pool for IMC access. Change the from and size to what you would like

resource "intersight_ippool_pool" "ippool_pool1" {
  name = "${var.policy_prefix}-ip-pool"
  description = var.description
  assignment_order = "sequential"
  ip_v4_blocks {
    from = "10.92.101.101"
    size = "16"
  }
  ip_v4_config {
    object_type = "ippool.IpV4Config"
    gateway = "10.92.101.1"
    netmask = "255.255.255.0"
    primary_dns = "10.101.128.15"
    }
  organization {
      object_type = "organization.Organization"
      moid = var.organization
      }
}

# Create a sequential MAC pool for vNICs. Change the from and size to what you would like

resource "intersight_macpool_pool" "macpool_pool1" {
  name = "${var.policy_prefix}-mac-pool"
  description = var.description
  assignment_order = "sequential"
  mac_blocks {
    object_type = "macpool.Block"
    from        = var.mac-block
    size          = "255"
    }
  organization {
    object_type = "organization.Organization"
    moid = var.organization 
    }
}

# Create a sequential WWNN and two WWPN (A and B fabirc) pool for vHBAs. Change the from and size to what you would like
#
# Comment out from here down to the end of the file if you do not want WWNN, WWPN-A and WWPN-B pools created

resource "intersight_fcpool_pool" "fcpool_pool0" {
  name = "${var.policy_prefix}-wwnn-pool"
  description = var.description
  assignment_order = "sequential"
  pool_purpose = "WWNN"
  id_blocks {
    #from        = "20:00:00:25:B5:E1:00:00"
    from        = var.wwnn-block
    size        =  255
    }
  organization {
    object_type = "organization.Organization"
    moid = var.organization 
    }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

resource "intersight_fcpool_pool" "fcpool_pool1" {
  name = "${var.policy_prefix}-wwpn-a-pool"
  description = var.description
  assignment_order = "sequential"
  pool_purpose = "WWPN"
  id_blocks {
    from        = var.wwpn-a-block
    size        =  255
    }
  organization {
    object_type = "organization.Organization"
    moid = var.organization 
    }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

resource "intersight_fcpool_pool" "fcpool_pool2" {
  name = "${var.policy_prefix}-wwpn-b-pool"
  description = var.description
  assignment_order = "sequential"
  pool_purpose = "WWPN"
  id_blocks {
    from        = var.wwpn-b-block
    size        =  255
    }
  organization {
    object_type = "organization.Organization"
    moid = var.organization 
    }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}
 
resource "intersight_uuidpool_pool" "uuid_pool1" {
  assignment_order = "sequential"
  description      = var.description
  name = "${var.policy_prefix}-uuid_pool1"
  prefix           = "000025B5-E100-0000"
  uuid_suffix_blocks {
    object_type = "uuidpool.UuidBlock"
    from        = var.uuid-block
    size          = "128"
    }
  organization {
    object_type = "organization.Organization"
    moid        = var.organization
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}
