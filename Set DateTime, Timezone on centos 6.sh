#!/bin/bash
#Change Timezone in Linux
mv /etc/localtime /etc/localtime.bk
cp /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
#Change Date and Time in Linux
#date MMDDhhmmYYYY

# Sync your system time and date with ntp (Network Time Protocol) over internet
yum install -y ntp
ntpdate pool.ntp.org
