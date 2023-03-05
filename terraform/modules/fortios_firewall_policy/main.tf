terraform {
  required_providers {
    fortios = {
      source            = "fortinetdev/fortios"
    }
  }
}

# Firewall Policy 설정
resource "fortios_firewall_policy" "default" {
    name                = var.name
    dynamic "srcintf" {
      for_each = var.srcintf
      content {
        name = srcintf.value["name"]
      }
    }
    dynamic "dstintf" {
      for_each = var.dstintf
      content {
        name = dstintf.value["name"]
      }
    }
    dynamic "srcaddr" {
      for_each = var.srcaddr
      content {
        name = srcaddr.value["name"]
      }
    }
    dynamic "dstaddr" {
      for_each = var.dstaddr
      content {
        name = dstaddr.value["name"]
      }
    }
    action		        = var.action
    schedule		    = var.schedule
    dynamic "service" {
      for_each = var.service
      content {
        name = service.value["name"]
      }
    }
    nat                 = var.nat
    tcp_mss_sender      = var.tcp_mss_sender
    tcp_mss_receiver    = var.tcp_mss_receiver
    logtraffic          = var.logtraffic
}