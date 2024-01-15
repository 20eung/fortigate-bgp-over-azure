provider "fortios" {
    hostname              = var.hostname
    token                 = var.token
    insecure              = var.insecure
    cabundlefile          = var.cabundlefile
 }


module "ipsecvpn" {

    source                = "../modules/ipsec_vpn"
    
    ### IPsec VPN Phase1-interface 설정
    name                  = "ipsecvpn"
    interface             = "wan1"
    proposal_phase1       = "aes256-sha1"  # default = aes128-sha256 aes256-sha256 aes128-sha1 aes256-sha1
    remote_gw             = "kofg60f1.fortiddns.com"
    psksecret	            = "PreSharedKey"
    ike_version           = "2"            # default = 1
    keylife               = 28800          # default = 86400
    mode                  = "main"         # default = main
    peertype              = "any"          # default = any
    net_device	          = "disable"      # default = disable
    dpd                   = "on-idle"      # default = on-demand  
    dhgrp_phase1          = "2"            # default = 14 5
    nattraversal          = "enable"       # default = enable
    dpd_retryinterval     = "10"           # default = 20
    
    ### IPsec VPN Phase2-interface 설정
    proposal_phase2       = "aes256-sha1"
    auto_negotiate        = "enable"       # default = disable
    pfs	                  = "enable"       # default = enable
    dhgrp_phase2          = "2"            # default = 14 5
    replay                = "enable"       # default = enable
    keepalive             = "disable"      # default = disable
    keylifeseconds        = 27000          # default = 43200

    ### System Interface 설정
    vdom                  = "root"         # default = "root"
    ip                    = "2.2.1.2 255.255.255.255"
    remote_ip             = "2.2.1.1 255.255.255.252"
    allowaccess           = "ping"         # default = unset allowaccess
    tcp_mss               = 1350           # default = 0
#   mtu_override          = "disable"      # default = disable
#   mtu                   = 1500           # default = 1500
#   autogenerated         = "on"           # required
}

module "ipsecvpn-to-wan1" {
    source                = "../modules/firewall_policy"

    name                  = "ipsecvpn-to-wan1"
    srcintf               = [
      { name              = "ipsecvpn" }
    ]
    dstintf               =  [
      { name              = "wan1" }
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
    nat                   = "enable"
    tcp_mss_sender        = "1350"
    tcp_mss_receiver      = "1350"
    logtraffic            = "all"
}

module "vlan10" {
    source                = "../modules/interface"

    name                  = "vlan10"
    vdom                  = "root"         # default = "root"
    device_identification = "enable"
    role                  = "lan"
    interface             = "internal1"
    vlanid                = 10             # range   = 1 - 4094
}

/*
module "vlan20" {
    source                = "../modules/interface"

    name                  = "vlan20"
    vdom                  = "root"         # default = "root"
    device_identification = "enable"
    role                  = "lan"
    interface             = "internal1"
    vlanid                = 20             # range   = 1 - 4094
}
*/

module "vxlan10" {
    source                = "../modules/vxlan"

    name                  = "vxlan.10"
    interface             = "ipsecvpn"
    vni                   = 10
    remote_ip             = "2.2.1.1"

    depends_on            = [ module.vlan10 ]
}

/*
module "vxlan20" {
    source                = "../modules/vxlan"

    name                  = "vxlan.20"
    interface             = "ipsecvpn"
    vni                   = 20
    remote_ip             = "2.2.1.1"

    depends_on            = [ module.vlan20 ]
}
*/

module "vxlan10svi" {
    source                = "../modules/switch_interface"

    name                  = "vxlan10"
    vdom                  = "root"         # default = "root"
    member                = [ 
      { interface_name    = "vlan10" },
      { interface_name    = "vxlan.10" }
    ]
#   type                  = "switch"
#   intra_switch_policy   = "implicit"
#   mac_ttl               = 300
#   span                  = "disable"

    depends_on             = [ module.vxlan10 ]
}

/*
module "vxlan20svi" {
    source                = "../modules/switch_interface"

    name                  = "vxlan20"
    vdom                  = "root"         # default = "root"
#   member                = ["vlan20", "vxlan.20"]
    member                = [ 
      { interface_name    = "vlan20" },
      { interface_name    = "vxlan.20" }
    ]
#   type                  = "switch"
#   intra_switch_policy   = "implicit"
#   mac_ttl               = 300
#   span                  = "disable"

    depends_on            = [ module.vxlan20 ]
}
*/

/*
module "llcf_wan1-internal1" {
    source                = "../modules/interface"

    name                  = "wan1"
    vdom                  = "root"

    fail_detect           = "enable"
    fail_detect_option    = "link-down"
    fail_alert_method     = "link-down"
    fail_alert_interfaces = [
        { name            = "internal1" }
    ]

    autogenerated         = "auto"
}
*/

/*
module "llcf_down_vpn-internal1" {
    source                = "../modules/automation"

    # system automation-action
    action_name           = "internal1_down"
    accprofile            = "api_super_admin"
    action_type           = "cli-script"
    required              = "enable"
    script                = "config system interface\nedit internal1\nset status down\nend"

    # system automation-trigger
    # logid 37138 = IPsec connection status changed
    event_type            = "event-log"
    logid                 = "37138"
    fields                = [{
      id                  = "1"
      name                = "action"
      value               = "tunnel-down"
    }]

    # system automation-stitch
    stitch_name           = "IPsec_VPN_tunnel_down"
    status                = "enable"
    trigger               = "IPsec_VPN_tunnel_down"
    action                = [
      { name              = "internal1_down" }
    ]
}
*/

/*
module "llcf_up_vpn-internal1" {
    source                = "../modules/automation"

    # system automation-action
    action_name           = "internal1_up"
    accprofile            = "api_super_admin"
    action_type           = "cli-script"
    required              = "enable"
    script                = "config system interface\nedit internal1\nset status up\nend"

    # system automation-trigger
    # logid 37138 = IPsec connection status changed
    event_type            = "event-log"
    logid                 = "37138"
    fields                = [{
      id                  = "1"
      name                = "action"
      value               = "tunnel-up"
    }]

    # system automation-stitch
    stitch_name           = "IPsec_VPN_tunnel_up"
    status                = "enable"
    trigger               = "IPsec_VPN_tunnel_up"
    action                = [
      { name              = "internal1_up" }
    ]
}
*/

/*
module "llcf_down_internal1-vpn" {
    source                = "../modules/automation"

    # system automation-action
    action_name           = "vpn_down"
    accprofile            = "api_super_admin"
    action_type           = "cli-script"
    required              = "enable"
    script                = "config system interface\nedit ipsecvpn\nset status down\nend"

    # system automation-trigger
    # logid 20099 = internal1 status changed
    event_type            = "event-log"
    logid                 = "20099"
    fields                = [
      {
        id                  = "1"
        name                = "msg"
        value               = "Link monitor: Interface internal1 was turned down"
      }
    ]

    # system automation-stitch
    stitch_name           = "internal1_interface_status_down"
    status                = "enable"
    trigger               = "internal1_interface_status_down"
    action                = [
      { name              = "vpn_down" }
    ]
}
*/

/*
module "llcf_up_internal1-vpn" {
    source                = "../modules/automation"

    # system automation-action
    action_name           = "vpn_up"
    accprofile            = "api_super_admin"
    action_type           = "cli-script"
    required              = "enable"
    script                = "config system interface\nedit ipsecvpn\nset status up\nend"

    # system automation-trigger
    # logid 20099 = internal1 status changed
    event_type            = "event-log"
    logid                 = "20099"
    fields                = [{
        id                  = "1"
        name                = "msg"
        value               = "Link monitor: Interface internal1 was turned up"
    }]

    # system automation-stitch
    stitch_name           = "internal1_interface_status_up"
    status                = "enable"
    trigger               = "internal1_interface_status_up"
    action                = [
      { name              = "vpn_up" }
    ]
}
*/

/*
module "llcf_down_vlan10-vxlan10" {
    source                = "../modules/automation"

    # system automation-action
    action_name           = "vxlan10_down"
    accprofile            = "api_super_admin"
    action_type           = "cli-script"
    required              = "enable"
    script                = "config system interface\nedit vxlan.10\nset status down\nend"

    # system automation-trigger
    # logid 20099 = internal1 status changed
    event_type            = "event-log"
    logid                 = "20099"
    fields                = [
      {
        id                  = "1"
        name                = "msg"
        value               = "Link monitor: Interface vlan10 was turned down"
      }
    ]

    # system automation-stitch
    stitch_name           = "vlan10_status_down"
    status                = "enable"
    trigger               = "vlan10_status_down"
    action                = [
      { name              = "vxlan10_down" }
    ]
}
*/

module "automation_action_vpn_down" {
    source                = "../modules/automation/action"

    # system automation-action
    action_name           = "ipsecvpn_down"
    accprofile            = "api_super_admin"
    action_type           = "cli-script"
    required              = "enable"
    script                = "config system interface\nedit ipsecvpn\nset status down\nend"
}

module "automation_action_vpn_up" {
    source                = "../modules/automation/action"

    # system automation-action
    action_name           = "ipsecvpn_up"
    action_type           = "cli-script"
    delay                 = 5
    required              = "enable"
    script                = "config system interface\nedit ipsecvpn\nset status up\nend"
    accprofile            = "api_super_admin"
}

module "automation_action_internal1_down" {
    source                = "../modules/automation/action"

    # system automation-action
    action_name           = "internal1_down"
    accprofile            = "api_super_admin"
    action_type           = "cli-script"
    required              = "enable"
    script                = "config system interface\nedit internal1\nset status down\nend"
}

module "automation_action_internal1_up" {
    source                = "../modules/automation/action"

    # system automation-action
    action_name           = "internal1_up"
    action_type           = "cli-script"
    delay                 = 5
    required              = "enable"
    script                = "config system interface\nedit internal1\nset status up\nend"
    accprofile            = "api_super_admin"
}

module "trigger_internal1_down" {
    source                = "../modules/automation/trigger"

    trigger_name          = "internal1_down"
    # system automation-trigger
    # logid 20099 = interface status changed
    event_type            = "event-log"
    logid                 = "20099"
    fields                = [
      {
        id                  = "1"
        name                = "msg"
        value               = "Link monitor: Interface internal1 was turned down"
      }
    ]
}

module "trigger_internal1_up" {
    source                = "../modules/automation/trigger"

    trigger_name          = "internal1_up"
    # system automation-trigger
    # logid 20099 = interface status changed
    event_type            = "event-log"
    logid                 = "20099"
    fields                = [
      {
        id                  = "1"
        name                = "msg"
        value               = "Link monitor: Interface internal1 was turned up"
      }
    ]
}

module "trigger_ipsecvpn_down" {
    source                = "../modules/automation/trigger"

    trigger_name          = "ipsecvpn_down"
    # system automation-trigger
    # logid 37138 = IPsec connection status changed
    event_type            = "event-log"
    logid                 = "37138"
    fields                = [{
      id                  = "1"
      name                = "action"
      value               = "tunnel-down"
    }]
}

module "trigger_ipsecvpn_up" {
    source                = "../modules/automation/trigger"

    trigger_name          = "ipsecvpn_up"
    # system automation-trigger
    # logid 37138 = IPsec connection status changed
    event_type            = "event-log"
    logid                 = "37138"
    fields                = [{
      id                  = "1"
      name                = "action"
      value               = "tunnel-up"
    }]
}

module "stitch_down_internal1-ipsecvpn" {
    source                = "../modules/automation/stitch"

    # system automation-stitch
    stitch_name           = "ipsecvpn_down"
    status                = "enable"
    trigger               = "internal1_down"
    action                = [
      { name              = "ipsecvpn_down" }
    ]
}

module "stitch_up_internal1-ipsecvpn" {
    source                = "../modules/automation/stitch"

    # system automation-stitch
    stitch_name           = "ipsecvpn_up"
    status                = "enable"
    trigger               = "internal1_up"
    action                = [
      { name              = "ipsecvpn_up" }
    ]
}

module "stitch_down_ipsecvpn-internal1" {
    source                = "../modules/automation/stitch"

    # system automation-stitch
    stitch_name           = "internal1_down"
    status                = "enable"
    trigger               = "ipsecvpn_down"
    action                = [
      { name              = "internal1_down" }
    ]
}

module "stitch_up_ipsecvpn-internal1" {
    source                = "../modules/automation/stitch"

    # system automation-stitch
    stitch_name           = "internal1_up"
    status                = "enable"
    trigger               = "ipsecvpn_up"
    action                = [
      { name              = "internal1_up" }
    ]
}