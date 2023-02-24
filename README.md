# 포티게이트 장비에서 BGP over Cloud 구현(Azure Cloud)

## 구성도
![Diagram](./img/diagram.png "Diagram")


## 1. WAN 인터페이스 설정

<table>
<tr>
  <td>FG#1</td>
  <td>FG#2</td>
</tr>
<tr>
  <td>

```
config system interface
  edit "wan1"
    set vdom "root"
    set ip 1.1.1.1 255.255.255.0
    set allowaccess ping fgfm
    set type physical
    set role wan
  next
end
```

  </td>
  <td>

```
config system interface
  edit "wan1"
    set vdom "root"
    set ip 1.1.1.2 255.255.255.0
    set allowaccess ping fgfm
    set type physical
    set role wan
  next
end
```

  </td>
</tr>
</table>


## 2. IPsec VPN 터널 설정

<table>
<tr>
  <td>FG#1</td>
  <td>FG#2</td>
</tr>
<tr>
  <td>

```
config vpn ipsec phase1-interface
  edit "azvpn1"
    set interface "wan1"
    set peertype any
    set net-device disable
    set proposal aes256-sha1
    set remote-gw 1.1.1.2
    set psksecret PreSharedKey
  next
end

config vpn ipsec phase2-interface
  edit "azvpn1"
    set phase1name "azvpn1"
    set proposal aes256-sha1
    set auto-negotiate enable
  next
end

config system interface
  edit "azvpn1"
    set vdom "root"
    set ip 2.2.1.1 255.255.255.255
    set allowaccess ping
    set type tunnel
    set remote-ip 2.2.1.2 255.255.255.252
    set interface "wan1"
  next
end
```

  </td>
  <td>

```
config vpn ipsec phase1-interface
  edit "ipsecvpn"
    set interface "wan1"
    set peertype any
    set net-device disable
    set proposal aes256-sha1
    set remote-gw 1.1.1.1
    set psksecret PreSharedKey
  next
end

config vpn ipsec phase2-interface
  edit "ipsecvpn"
    set phase1name "ipsecvpn"
    set proposal aes256-sha1
    set auto-negotiate enable
  next
end

config system interface
  edit "ipsecvpn"
    set vdom "root"
    set ip 2.2.1.2 255.255.255.255
    set allowaccess ping
    set type tunnel
    set remote-ip 2.2.1.1 255.255.255.252
    set interface "wan1"
  next
end
```

  </td>
</tr>
</table>



## 3. VLAN 인터페이스 설정

<table>
<tr>
  <td>FG#1</td>
  <td>FG#2</td>
</tr>
<tr>
  <td>

```
config system interface
  edit "vlan10"
    set vdom "root"
    set device-identification enable
    set role lan
    set interface "internal1"
    set vlanid 10
  next
end  
```

  </td>
  <td>

```
config system interface
  edit "vlan10"
    set vdom "root"
    set device-identification enable
    set role lan
    set interface "internal1"
    set vlanid 10
  next
end  
```

  </td>
</tr>
</table>


## 4. Firewall Policy 설정

<table>
<tr>
  <td>FG#1</td>
  <td>FG#2</td>
</tr>
<tr>
  <td>

```
config firewall policy
    edit 0
        set name "ipsecvpn-to-azure"
        set srcintf "ipsecvpn"
        set dstintf "azure-us-1" "azure-us-2"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
        set logtraffic all
#       set tcp-mss-sender 1350
#       set tcp-mss-receiver 1350
    next
    edit 0
        set name "azure-to-us_site_vlan"
        set srcintf "azure-us-1" "azure-us-2"
        set dstintf "us_site_vlan"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
        set logtraffic all
#       set tcp-mss-sender 1350
#       set tcp-mss-receiver 1350
    next
end 