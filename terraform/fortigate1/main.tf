provider "fortios" {
    hostname              = var.hostname
    token                 = var.token
    insecure              = var.insecure
    cabundlefile          = var.cabundlefile
 }


module "azvpn1_phase1interface" {

    source                = "git@github.com:20eung/terraform-fortios-modules.git//modules/fortios_vpnipsec_phase1interface?ref=v1.0.0"
    
    ### IPsec VPN Phase1-interface 설정
    name                  = "azvpn1"

    interface             = "wan2"
    ike_version           = "2"            # default = 1
    keylife               = 28800          # default = 86400
    peertype              = "any"          # default = any
    net_device	          = "disable"      # default = disable
    proposal              = "aes256-sha1"  # default = aes128-sha256 aes256-sha256 aes128-sha1 aes256-sha1
    dpd                   = "on-idle"      # default = on-demand  
    dhgrp                 = "2"            # default = 14 5
    remote_gw             = "20.187.150.218"
    psksecret	            = "sknetvpn"
    dpd_retryinterval     = "10"           # default = 20
}

module "azvpn2_phase1interface" {

    source                = "git@github.com:20eung/terraform-fortios-modules.git//modules/fortios_vpnipsec_phase1interface?ref=v1.0.0"
    
    ### IPsec VPN Phase1-interface 설정
    name                  = "azvpn2"

    interface             = "wan2"
    ike_version           = "2"            # default = 1
    keylife               = 28800          # default = 86400
    peertype              = "any"          # default = any
    net_device	          = "disable"      # default = disable
    proposal              = "aes256-sha1"  # default = aes128-sha256 aes256-sha256 aes128-sha1 aes256-sha1
    dpd                   = "on-idle"      # default = on-demand  
    dhgrp                 = "2"            # default = 14 5
    remote_gw             = "20.187.150.105"
    psksecret	            = "sknetvpn"
    dpd_retryinterval     = "10"           # default = 20
}


module "azvpn1_phase2interface" {

    source                = "git@github.com:20eung/terraform-fortios-modules.git//modules/fortios_vpnipsec_phase2interface?ref=v1.0.0"
    
    ### IPsec VPN Phase2-interface 설정
    name                  = "azvpn1"

    phase1name            = "azvpn1"
    proposal              = "aes256-sha1"
    dhgrp                 = "2"            # default = 14 5
    auto_negotiate        = "enable"       # default = disable
    keylifeseconds        = 27000          # default = 43200
}

module "azvpn2_phase2interface" {

    source                = "git@github.com:20eung/terraform-fortios-modules.git//modules/fortios_vpnipsec_phase2interface?ref=v1.0.0"
    
    ### IPsec VPN Phase2-interface 설정
    name                  = "azvpn2"

    phase1name            = "azvpn2"
    proposal              = "aes256-sha1"
    dhgrp                 = "2"            # default = 14 5
    auto_negotiate        = "enable"       # default = disable
    keylifeseconds        = 27000          # default = 43200
}

module "azvpn1_interface" {

    source                = "git@github.com:20eung/terraform-fortios-modules.git//modules/fortios_system_interface?ref=v1.0.0"
    
    ### System Interface 설정
    name                  = "azvpn1"

    vdom                  = "root"         # default = "root"
    ip                    = "2.2.1.1 255.255.255.255"
    remote_ip             = "2.2.1.3 255.255.255.248"
    allowaccess           = "ping"         # default = unset allowaccess
    tcp_mss               = 1350           # default = 0
}

module "azvpn2_interface" {

    source                = "git@github.com:20eung/terraform-fortios-modules.git//modules/fortios_system_interface?ref=v1.0.0"
    
    ### System Interface 설정
    name                  = "azvpn1"

    vdom                  = "root"         # default = "root"
    ip                    = "2.2.2.1 255.255.255.255"
    remote_ip             = "2.2.2.3 255.255.255.248"
    allowaccess           = "ping"         # default = unset allowaccess
    tcp_mss               = 1350           # default = 0
}

module "azvpn_policy_1" {

    source                = "git@github.com:20eung/terraform-fortios-modules.git//modules/fortios_firewall_policy?ref=v1.0.0"
    

    name                  = "internal1_to_azvpn"
    srcintf               = [
      { name              = "internal1" }
    ]
    dstintf               = [
      { name              = "azvpn1" },
      { name              = "azvpn2" }
    ]
    srcaddr               = [
      { name              = "all" }
    ]
    dstaddr               = [
      { name              = "all" }
    ]
    action                = "accept"
    schedule              = "always"
    service               = [
      { name              = "ALL" }
    ]
    nat                   = "disable"
    logtraffic            = "all"
}

module "azvpn_policy_2" {

    source                = "git@github.com:20eung/terraform-fortios-modules.git//modules/fortios_firewall_policy?ref=v1.0.0"
    

    name                  = "azvpn_to_internal1"
    srcintf               = [
      { name              = "azvpn1" },
      { name              = "azvpn2" }
    ]
    dstintf               = [
      { name              = "internal1" }
    ]
    srcaddr               = [
      { name              = "all" }
    ]
    dstaddr               = [
      { name              = "all" }
    ]
    action                = "accept"
    schedule              = "always"
    service               = [
      { name              = "ALL" }
    ]
    nat                   = "disable"
    logtraffic            = "all"
}

module "internal1_interface" {

    source                = "git@github.com:20eung/terraform-fortios-modules.git//modules/fortios_system_interface?ref=v1.0.0"
    
    ### System Interface 설정

    name                  = "internal1"

    vdom                  = "root"         # default = "root"
    ip                    = "10.10.0.1 255.255.255.0"
    allowaccess           = "ping"          # range   = 1 - 4094
}

module "vlan10_interface" {

    source                = "git@github.com:20eung/terraform-fortios-modules.git//modules/fortios_system_interface?ref=v1.0.0"
    
    ### System Interface 설정

    name                  = "vlan10"

    vdom                  = "root"         # default = "root"
    device_identification = "enable"
    role                  = "lan"
    interface             = "internal1"
    vlanid                = 10             # range   = 1 - 4094
}

module "azvpn1_bgpip_static_routing" {

    source                = "git@github.com:20eung/terraform-fortios-modules.git//modules/fortios_router_static?ref=v1.0.0"
    
    ### Static Routing 설정

    dst                   = "10.232.213.12 255.255.255.255"
    device                = "azvpn1"
    comment               = "AzVpnBgp1"
}

module "azvpn2_bgpip_static_routing" {

    source                = "git@github.com:20eung/terraform-fortios-modules.git//modules/fortios_router_static?ref=v1.0.0"
    
    ### Static Routing 설정

    dst                   = "10.232.213.13 255.255.255.255"
    device                = "azvpn2"
    comment               = "AzVpnBgp2"
}

module "tunnel1_accesslist" {

    source                = "git@github.com:20eung/terraform-fortios-modules.git//modules/fortios_router_accesslist?ref=v1.0.0"
    
    ### AccessList 설정

    name                  = "tunnel1"

    rule                  = [{
      prefix              = "2.2.1.1 255.255.255.255"
    }]
}

module "tunnel2_accesslist" {

    source                = "git@github.com:20eung/terraform-fortios-modules.git//modules/fortios_router_accesslist?ref=v1.0.0"
    
    ### AccessList 설정

    name                  = "tunnel2"

    rule                  = [{
      prefix              = "2.2.2.1 255.255.255.255"
    }]
}

module "vlan10_accesslist" {

    source                = "git@github.com:20eung/terraform-fortios-modules.git//modules/fortios_router_accesslist?ref=v1.0.0"
    
    ### AccessList 설정

    name                  = "vlan10"

    rule                  = [{
      prefix              = "10.10.0.0 255.255.255.0"
    }]
}

module "bgp_routing" {

    source                = "git@github.com:20eung/terraform-fortios-modules.git//modules/fortios_router_bgp?ref=v1.0.0"
    
    ### BGP Routing 설정

    as                    = 65010
    router_id             = "10.10.0.1"
    ebgp_multipath        = "enable"
    graceful_restart      = "enable"

    neighbor              = [
      {
        ip                     = "10.232.213.12"
        ebgp_enforce_multihop  = "enable"
        soft_reconfiguration   = "enable"
        distribute_list_out    = "tunnel1"
        remote_as              = 65515
      }
      {
        ip                     = "10.232.213.13"
        ebgp_enforce_multihop  = "enable"
        soft_reconfiguration   = "enable"
        distribute_list_out    = "tunnel2"
        remote_as              = 65515
      }
      {
        ip                     = "2.2.1.2"
        ebgp_enforce_multihop  = "enable"
        soft_reconfiguration   = "enable"
        distribute_list_out    = "vlan10"
        remote_as              = 65020
      }
      {
        ip                     = "2.2.2.2"
        ebgp_enforce_multihop  = "enable"
        soft_reconfiguration   = "enable"
        distribute_list_out    = "vlan10"
        remote_as              = 65020
      }
    ]

    network               = [
      {
        id                     = 1
        prefix                 = "2.2.1.1 255.255.255.255"
      }
      {
        id                     = 2
        prefix                 = "2.2.2.1 255.255.255.255"
      }
      {
        id                     = 3
        prefix                 = "10.10.0.0 255.255.255.0"
      }
    ]
}
