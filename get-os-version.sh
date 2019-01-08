#!/bin/bash

# Global variable
OS_DISTRO="unknown"
OS_DISTRO_VER="unknown"

# Check OS Distro and Version
if [[ -f /etc/redhat-release ]];then
    OS_DISTRO="Centos"
    OS_DISTRO_VER=$(grep -oE '[0-9]+\.[0-9]+' /etc/redhat-release)

elif [[ -f /etc/lsb-release ]]; then
    OS_DISTRO="Ubuntu"
    OS_DISTRO_VER="$(grep "DISTRIB_RELEASE" /etc/lsb-release | awk -F'=' '{print $2}' | sed 's/[[:blank:]]//g')"

    if [[ -z ${OS_DISTRO_VER} ]] || [[ ${OS_DISTRO_VER} == "" ]];then
        OS_DISTRO_VER=$(lsb_release -a | grep -i "Release" | awk -F':' '{print $2}' | sed 's/[[:blank:]]//g')
    fi

elif [[ -f /etc/debian_version ]]; then
    OS_DISTRO="Debian"
    OS_DISTRO_VER="$(cat /etc/debian_version | sed 's/[[:blank:]]//g')"

    if [[ -z ${OS_DISTRO_VER} ]] || [[ ${OS_DISTRO_VER} == "" ]];then
        OS_DISTRO_VER=$(lsb_release -a | grep -i "Release" | awk -F':' '{print $2}' | sed 's/[[:blank:]]//g')
    fi
fi

# Print result
echo $OS_DISTRO
echo $OS_DISTRO_VER

exit 0
