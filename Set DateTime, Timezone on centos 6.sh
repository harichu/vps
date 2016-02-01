#!/bin/bash
#Change Timezone in Linux
sudo mv /etc/localtime /etc/localtime.bk
sudo cp /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
#Change Date and Time in Linux
#date MMDDhhmmYYYY

# Sync your system time and date with ntp (Network Time Protocol) over internet
sudo yum install -y ntp
sudo ntpdate pool.ntp.org
