# This file creates the following policies:
#    - boot order
#    - ntp
#    - network connectivity (dns)
#    - multicast
#    - Virtual KVM (enable KVM)
#    - Virtual Media
#    - System QoS
#    - IMC Access
#    - BIOS
#    - IAM user
#    - Power Policy

# =============================================================================
# Boot Precision (boot order) Policy
# -----------------------------------------------------------------------------

resource "intersight_boot_precision_policy" "boot_precision1" {
  name                     = "${var.policy_prefix}-boot-order"
  description              = var.description
  configured_boot_mode     = "Uefi"
  enforce_uefi_secure_boot = false
  boot_devices {
    enabled     = true
    name        = "KVM_DVD"
    object_type = "boot.VirtualMedia"
    additional_properties = jsonencode({
      Subtype = "kvm-mapped-dvd"
    })
  }
  boot_devices {
    enabled     = true
    name        = "IMC_DVD"
    object_type = "boot.VirtualMedia"
    additional_properties = jsonencode({
      Subtype = "cimc-mapped-dvd"
    })
  }
  boot_devices {
    enabled     = true
    name        = "LocalDisk"
    object_type = "boot.LocalDisk"
    additional_properties = jsonencode({
      Slot = "MSTOR-RAID"
      Bootloader = {
        Description = ""
        Name        = ""
        ObjectType  = "boot.Bootloader"
        Path        = ""
      }
     })
  }
  organization {
    moid        = var.organization
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}


# =============================================================================
# Device Connector Policy (optional)
# -----------------------------------------------------------------------------
#
#resource "intersight_deviceconnector_policy" "dc1" {
#  description     = var.description
#  lockout_enabled = true
#  name            = "${var.policy_prefix}-device-connector"
#  organization {
#    moid        = var.organization
#    object_type = "organization.Organization"
#  }
#  dynamic "tags" {
#    for_each = var.tags
#    content {
#      key   = tags.value.key
#      value = tags.value.value
#    }
#  }
#}


# =============================================================================
# NTP Policy
# -----------------------------------------------------------------------------

resource "intersight_ntp_policy" "ntp1" {
  description = var.description
  enabled     = true
  name        = "${var.policy_prefix}-ntp"
  timezone    = var.ntp_timezone
  ntp_servers = var.ntp_servers
  organization {
    moid        = var.organization
    object_type = "organization.Organization"
  }
  # assign this policy to the domain profile being created
  profiles {
    moid        = intersight_fabric_switch_profile.fabric_switch_profile_a.moid
    object_type = "fabric.SwitchProfile"
  }
  profiles {
    moid        = intersight_fabric_switch_profile.fabric_switch_profile_b.moid
    object_type = "fabric.SwitchProfile"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}


# =============================================================================
# IPMI over LAN (optional)
# -----------------------------------------------------------------------------
#
#resource "intersight_ipmioverlan_policy" "ipmi2" {
#  description = var.description
#  enabled     = false
#  name        = "${var.policy_prefix}-ipmi-disabled"
#  organization {
#    moid        = var.organization
#    object_type = "organization.Organization"
#  }
#  dynamic "tags" {
#    for_each = var.tags
#    content {
#      key   = tags.value.key
#      value = tags.value.value
#    }
#  }
#}


# =============================================================================
# Network Connectivity (DNS)
# -----------------------------------------------------------------------------

# IPv6 is enabled because this is the only way that the provider allows the
# IPv6 DNS servers (primary and alternate) to be set to something. If it is not
# set to something other than null in this resource, then terraform "apply"
# will detect that thare changes to apply every time ("::" -> null).

resource "intersight_networkconfig_policy" "connectivity1" {
  alternate_ipv4dns_server = var.dns_alternate
  preferred_ipv4dns_server = var.dns_preferred
  description              = var.description
  enable_dynamic_dns       = false
  enable_ipv4dns_from_dhcp = false
  enable_ipv6              = false
  enable_ipv6dns_from_dhcp = false
  name                     = "${var.policy_prefix}-dns"
  organization {
    moid        = var.organization
    object_type = "organization.Organization"
  }
  # assign this policy to the domain profile being created
  profiles {
    moid        = intersight_fabric_switch_profile.fabric_switch_profile_a.moid
    object_type = "fabric.SwitchProfile"
  }
  profiles {
    moid        = intersight_fabric_switch_profile.fabric_switch_profile_b.moid
    object_type = "fabric.SwitchProfile"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

# =============================================================================
# Multicast
# -----------------------------------------------------------------------------

resource "intersight_fabric_multicast_policy" "fabric_multicast_policy1" {
  name               = "${var.policy_prefix}-multicast"
  description        = var.description
  querier_ip_address = ""
  querier_state      = "Disabled"
  snooping_state     = "Enabled"
  organization {
    moid        = var.organization
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

# =============================================================================
# BIOS
# -----------------------------------------------------------------------------

resource "intersight_bios_policy" "biosvirt" {
  name = "${var.policy_prefix}-biosvirt"
  
  ## Customizations
  cpu_perf_enhancement                  = "Auto"
  tpm_support                           = "disabled"
  processor_c1e                         = "disabled"
  lv_ddr_mode                           = "auto"

organization {
    moid        = var.organization
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

# =============================================================================
# IAM enpoint Policy
# -----------------------------------------------------------------------------


# This is the base policy, which does not include any users
resource "intersight_iam_end_point_user_policy" "user_policy1" {
  name = "user_policy1"
  description = "user policy1"
  organization {
    moid        = var.organization
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }

  password_properties {
    enforce_strong_password  = false
    enable_password_expiry   = false
    password_expiry_duration = 50
    password_history         = 5
    notification_period      = 1
    grace_period             = 3
  }

}

##  Admin user

# This resource is a user that will be added to the policy.
resource "intersight_iam_end_point_user" "admin" {
  name = "admin"
  organization {
    moid        = var.organization
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

# This data source retrieves a system built-in role that we want to assign to the admin user.
data "intersight_iam_end_point_role" "imc_admin" {
  name      = "admin"
  role_type = "endpoint-admin"
  type      = "IMC"
}

# This resource adds the user to the policy using the role we retrieved.
# Notably, the password is set in this resource and NOT in the user resource above.
resource "intersight_iam_end_point_user_role" "admin" {
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }

  enabled  = true
  password = var.imc_admin_password

  end_point_user {
    moid = intersight_iam_end_point_user.admin.moid
  }

  end_point_user_policy {
    moid = intersight_iam_end_point_user_policy.user_policy1.moid
  }

  end_point_role {
    moid = data.intersight_iam_end_point_role.imc_admin.results[0].moid
  }

}


# =============================================================================
# Virtual KVM Policy
# -----------------------------------------------------------------------------

resource "intersight_kvm_policy" "kvmpolicy1" {
  name                      = "${var.policy_prefix}-kvm-enabled"
  description               = var.description
  enable_local_server_video = true
  enable_video_encryption   = true
  enabled                   = true
  maximum_sessions          = 4
  organization {
    moid = var.organization
  }
  remote_port = 2068
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}


# =============================================================================
# Virtual Media Policy
# -----------------------------------------------------------------------------



resource "intersight_vmedia_policy" "vmedia2" {
  name          = "${var.policy_prefix}-vmedia-enabled"
  description   = var.description
  enabled       = true
  encryption    = true
  low_power_usb = true
  organization {
    moid        = var.organization
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

# =============================================================================
# System Qos Policy
# -----------------------------------------------------------------------------

# this will create the default System QoS policy with zero customization
resource "intersight_fabric_system_qos_policy" "qos1" {
  name        = "${var.policy_prefix}-system-qos"
  description = var.description
   classes {
    admin_state        = "Enabled"
    bandwidth_percent  = 6
    cos                = 1
    mtu                = 9000
    multicast_optimize = false
    name               = "Bronze"
    packet_drop        = true
    weight             = 1
  }

  classes {
    admin_state        = "Enabled"
    bandwidth_percent  = 6
    cos                = 2
    mtu                = 1500
    multicast_optimize = true
    name               = "Silver"
    packet_drop        = true
    weight             = 1
  }

  classes {
    admin_state        = "Enabled"
    bandwidth_percent  = 25
    cos                = 4
    mtu                = 1500
    multicast_optimize = false
    name               = "Gold"
    packet_drop        = true
    weight             = 4
  }

  classes {
    admin_state        = "Enabled"
    bandwidth_percent  = 25
    cos                = 5
    mtu                = 1500
    multicast_optimize = false
    name               = "Platinum"
    packet_drop        = false
    weight             = 4
  }

  classes {
    admin_state        = "Enabled"
    bandwidth_percent  = 6
    cos                = 255
    mtu                = 1500
    multicast_optimize = false
    name               = "Best Effort"
    packet_drop        = true
    weight             = 1
  }

  classes {
    admin_state        = "Enabled"
    bandwidth_percent  = 32
    cos                = 3
    mtu                = 2240
    multicast_optimize = false
    name               = "FC"
    packet_drop        = false
    weight             = 5
  }

  organization {
    moid        = var.organization
    object_type = "organization.Organization"
  }
  # assign this policy to the domain profile being created
  profiles {
    moid        = intersight_fabric_switch_profile.fabric_switch_profile_a.moid
    object_type = "fabric.SwitchProfile"
  }
  profiles {
    moid        = intersight_fabric_switch_profile.fabric_switch_profile_b.moid
    object_type = "fabric.SwitchProfile"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

# =============================================================================
# IMC Access
# -----------------------------------------------------------------------------

resource "intersight_access_policy" "access1" {
  name        = "${var.policy_prefix}-imc-access"
  description = var.description
  inband_vlan = var.imc_access_vlan
  inband_ip_pool {
    object_type = "ippool.Pool"
    #Pick one of the 2 next lines depending if you want to hard code the IMC IP Pool
    #moid        = var.imc_access_pool
    moid        = intersight_ippool_pool.ippool_pool1.moid
  }
  organization {
    moid        = var.organization
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

# =============================================================================
# Serial Over LAN (optional)
# -----------------------------------------------------------------------------
#
#resource "intersight_sol_policy" "sol1" {
#  name        = "${var.policy_prefix}-sol-off"
#  description = var.description
#  enabled     = false
#  baud_rate   = 9600
#  com_port    = "com1"
#  ssh_port    = 1096
#  organization {
#    moid        = var.organization
#    object_type = "organization.Organization"
#  }
#  dynamic "tags" {
#    for_each = var.tags
#    content {
#      key   = tags.value.key
#      value = tags.value.value
#    }
#  }
#}
# =============================================================================
# SNMP
# -----------------------------------------------------------------------------

resource "intersight_snmp_policy" "snmp_disabled" {
  name        = "${var.policy_prefix}-snmp-disabled"
  description = var.description
  enabled     = false
  organization {
    moid        = var.organization
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}
# =============================================================================
# Power - Grid
# -----------------------------------------------------------------------------
resource "intersight_power_policy" "grid_last_state" {
  name = "grid_last_state"
 
  power_profiling     = "Enabled"
  power_restore_state = "LastState"
  redundancy_mode     = "Grid"
  
  organization {
    moid        = var.organization
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}
