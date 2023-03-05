### fortios_vpnipsec_phase1interface

variable "auto_negotiate" {
  description = "(optional) default=disable"
  type        = string
  default     = null
}

variable "dhgrp_phase1" {
  description = "(optional) default=14 5"
  type        = string
  default     = null
}

variable "dpd" {
  description = "(optional) default=on-demand"
  type        = string
  default     = null
}

variable "dpd_retryinterval" {
  description = "(optional) default=20"
  type        = string
  default     = null
}

variable "ike_version" {
  description = "(optional) default=1"
  type        = string
  default     = null
}

variable "interface" {
  description = "(required)"
  type        = string
}

variable "keylife" {
  description = "(optional) default=86400"
  type        = number
  default     = null
}

variable "mode" {
  description = "(optional) default=main"
  type        = string
  default     = "main"
}

variable "name" {
  description = "(optional)"
  type        = string
  default     = null
}

variable "nattraversal" {
  description = "(optional) default=enable"
  type        = string
  default     = null
}

variable "net_device" {
  description = "(optional) default=disable"
  type        = string
  default     = null
}

variable "peertype" {
  description = "(optional) default=any"
  type        = string
  default     = null
}

variable "proposal_phase1" {
  description = "(required) default=aes128-sha256 aes256-sha256 aes128-sha1 aes256-sha1"
  type        = string
}

variable "psksecret" {
  description = "(optional)"
  type        = string
  default     = null
}

variable "remotegw_ddns" {
  description = "(optional)"
  type        = string
  default     = null
}

variable "remote_gw" {
  description = "(optional)"
  type        = string
  default     = null
}

variable "type" {
  description = "(required)"
  type        = string
}

### fortios_vpnipsec_phase2interface

variable "dhgrp_phase2" {
  description = "(optional) default=14 5"
  type        = string
  default     = null
}

variable "keepalive" {
  description = "(optional) default=disable"
  type        = string
  default     = null
}

variable "keylifeseconds" {
  description = "(optional) default=43200"
  type        = number
  default     = null
}

variable "pfs" {
  description = "(optional) default=enable"
  type        = string
  default     = null
}

variable "proposal_phase2" {
  description = "(required) default=aes128-sha256 aes256-sha256 aes128-sha1 aes256-sha1"
  type        = string
  default     = null
}

variable "replay" {
  description = "(optional) default=enable"
  type        = string
  default     = null
}


### fortios_system_interface

variable "allowaccess" {
  description = "(optional)"
  type        = string
  default     = null
}

variable "ip" {
  description = "(optional)"
  type        = string
  default     = null
}

variable "mtu" {
  description = "(optional)"
  type        = number
  default     = null
}

variable "mtu_override" {
  description = "(optional) default=disable"
  type        = string
  default     = null
}

variable "remote_ip" {
  description = "(optional)"
  type        = string
  default     = null
}

variable "tcp_mss" {
  description = "(optional) default=0"
  type        = number
  default     = null
}

variable "vdom" {
  description = "(required) default=root"
  type        = string
}
