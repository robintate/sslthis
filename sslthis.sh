#!/usr/bin/env bash

# Superbeta version numero zero

# Credit to SuperKojiMan for inspiration and template.

# Colors
ESC="\e["
RESET=$ESC"39m"
RED=$ESC"31m"
GREEN=$ESC"32m"
BLUE=$ESC"34m"
PURPLE=$ESC"35m"

function banner {

echo "     __________ __  ________  ___________"
echo "    / ___/ ___// / /_  __/ / / /  _/ ___/"
echo "    \__ \\__ \ / /   / / / /_/ // / \__ \ "
echo "   ___/ /__/ / /___/ / / __  // / ___/ / "
echo "  /____/____/_____/_/ /_/ /_/___//____/  "
echo "                  by Rob T.              "
echo ""
}

function usage {
  echo "Usage: $0 -t  targets.txt"
  echo "          -h: Help"
  echo "          -t: File containing IP addresses to scan. This option is required!"
  echo "          -i: Network Interface. Defaults to eth0"
}

banner

if [[ ! $(id -u) == 0 ]]; then
    echo -e "${RED}[!]${RESET} This script must be run as root"
    exit 1
fi

if [[ -z $(which sslscan) ]]; then
    echo -e "${RED}[!]${RESET} Unable to find SSLScan. Install it and make sure it's in your PATH   environment"
    exit 1
fi

if [[ -z $(which nmap) ]]; then
    echo -e "${RED}[!]${RESET} Unable to find NMap Install it and make sure it's in your PATH environment"
    exit 1
fi

if [[ -z $1 ]]; then
    usage
    exit 0
fi

iface="eth0"
nmap_opt="-sV --script ssl-enum-ciphers.nse -p 443"
targets=""

while getopts "t:i:h" OPT; do
  case $OPT in
    t) targets=${OPTARG};;
    i) iface=${OPTARG};;
    H) usage; exit 0;;
    *) usage; exit 0;;
  esac
done



if [[ -z $targets ]]; then
    echo "[!] No target file provided"
    usage
    exit 1
fi


echo -e "${PURPLE}[+]${RESET} Interface: ${iface} eth0"
echo -e "${PURPLE}[+]${RESET} Nmap opts: ${nmap_opt} SSL Enum Ciphers Script"
echo -e "${PURPLE}[+]${RESET} Targets  : ${targets}"




while read ip; do
    echo -e "${PURPLE}[+]${RESET} Scanning $ip for SSL Certificate Information..."

# sslscan program
  echo -e "${BLUE}[+]${RESET} sslscan ${ip}"
  sslscan ${iface} ${ip}
  echo -e "${BLUE}[+]${RESET} SSLScan Complete"
    # nmap follows up
    echo -e "${BLUE}[*]${RESET} Obtaining Qualys SSL Labs Rating per cipher"
    nmap -e ${iface} ${nmap_opt} ${ip}



done < ${targets}

echo -e "${GREEN}[+++]${RESET} SSL Enumeration Complete"
