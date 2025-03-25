#!/usr/bin/bash

# This shell script is to be used in conjunction with simh and the 211bsd+ OS
# This will bridge the simh tun network with the host's normal wired ethernet to allow the simh OS to use its own ip address
# Whether that address is static or dynamic is really up to how the simh OS is configured (of course I know of no dhcp client at this writing)
# If it is static be sure to choose an address that won't conflict with anything.  
# I define my network with dhcp pools that stop at *.*.*.199, and then add 200 to the last octet of the host address for the simh OS address

# My thanks to Sheepless in the PiDP-11 google group for the core commands in this script
# I converted his boot.ini changes to a HERE patch document. I also put his raw commands to create the tap 
#   bridge inside an if test to only run them if the bridge doesn't exist
# RanchoHam 21 Mar 2025

# This script must be run as root from the systems/2.11bsd+ directory
if ! [ "$UID" = 0 ]; then
echo "must be run as root (sudo OK)"
exit 1
fi

# Edit these addresses to match your network and host

#export HOST_ADDR=192.168.100.66/24
#export GATEWAY=192.168.100.1
#export DNS_LOCAL=192.168.100.3
#export DNS_SEARCH_DOMAINS=example.com

export HOST_ADDR=192.168.101.19/24
export GATEWAY=192.168.101.1
export DNS_LOCAL=192.168.10.100
export DNS_SEARCH_DOMAINS=orion.wb0nre.org,vega.orion.org

# If you use IPV6, set IPV4_ONLY to "NO" and define the correct HOST_IPV6_ADDR and GATEWAY_IPV6 variables
export IPV4_ONLY="YES"
export HOST_IPV6_ADDR=2001:db8:25:2::42/64
export GATEWAY_IPV6=2001:db8:25:2::2

while getopts ':H:G:D:S:h' opt; do
  case "$opt" in
    H)
      arg="$OPTARG"
      echo "Processing option 'H'"
      ;;

    G)
      arg="$OPTARG"
      echo "Processing option 'G'"
      ;;

    D)
      arg="$OPTARG"
      echo "Processing option 'D' with '${OPTARG}' argument"
      ;;

    S)
      arg="$OPTARG"
      echo "Processing option 'S' with '${OPTARG}' argument"
      ;;

    h)
      echo "Usage: $(basename $0) [-a] [-b] [-c arg]"
      exit 0
      ;;

    :)
      echo -e "option requires an argument.\nUsage: $(basename $0) [-a] [-b] [-c arg]"
      exit 1
      ;;

    ?)
      echo -e "Invalid command option.\nUsage: $(basename $0) [-a] [-b] [-c arg]"
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"
exit

# Don't modify after this line
# First apply the patch to change nat to tap & silently ignore if it has already been applied
patch -bNr - <<EoF
*** boot.ini.save	2025-03-21 12:21:04.502873060 -0700
--- boot.ini	2025-03-21 12:32:34.705007297 -0700
***************
*** 24,31 ****
  set xu enabled
  set xu type=delua
  ;attach xu eth0
! ;attach xu tap:tap-simh1
! attach xu nat:tcp=2121:10.0.2.15:21,tcp=2323:10.0.2.15:23
  
  sh xu
  sh eth
--- 24,31 ----
  set xu enabled
  set xu type=delua
  ;attach xu eth0
! attach xu tap:tap-simh1
! ;attach xu nat:tcp=2121:10.0.2.15:21,tcp=2323:10.0.2.15:23
  
  sh xu
  sh eth
EoF
# Test to see if the bridge doesn't exist and only then create the bridge
if ! [ -d  /sys/class/net/br0 ]; then
apt install bridge-utils
nmcli con add ifname br0 type bridge con-name br0
nmcli con add type bridge-slave ifname eth0 master br0
nmcli con modify br0 bridge.stp no
nmcli con down 'Wired connection 1'
nmcli con up br0
#nmcli con mod br0 ipv4.addresses 192.168.100.66/24 ipv4.method manual ipv4.gateway 192.168.100.1 ipv4.dns 192.168.100.3 ipv4.dns-search example.com \
#    ipv6.addresses 2001:db8:25:2::42/64 ipv6.method manual ipv6.gateway 2001:db8:25:2::2
if [ "$IPV4_ONLY" == "YES" ]; then
nmcli con mod br0 ipv4.addresses $HOST_ADDR ipv4.method manual ipv4.gateway $GATEWAY ipv4.dns $DNS_LOCAL ipv4.dns-search $DNS_SEARCH_DOMAINS 
else
nmcli con mod br0 ipv4.addresses $HOST_ADDR ipv4.method manual ipv4.gateway $GATEWAY ipv4.dns $DNS_LOCAL ipv4.dns-search $DNS_SEARCH_DOMAINS \
    ipv6.addresses $HOST_IPV6 ipv6.method manual ipv6.gateway $GATEWAY_IPV6
fi
nmcli con down br0
nmcli con up br0
nmcli con add type tun ifname tap-simh1 mode tap owner 1000 master br0
fi
