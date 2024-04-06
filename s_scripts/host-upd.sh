#!/usr/bin/env bash
#
#

source ~/.bashrc

cp /etc/hosts ${DOCKER_DIR}hosts

cat ${DOCKER_DIR}hosts_bkp > ${DOCKER_DIR}hosts

IFS=$'\n' read -r -d '' -a arry < <(timeout 60 nmap -sn 192.168.1.0/24 | grep -E 'Nmap scan.*\(' | grep -v '192.168.1.1' | cut -d'(' -f2 | cut -d')' -f1 | awk '{$1=$1};1')

if [ $? -eq 0 ]; then
    echo "IP address command ran successfully"
else
    exit 1
fi

IFS=$'\n' read -r -d '' -a arry2 < <(timeout 60 nmap -sn 192.168.1.0/24 | grep -E 'Nmap scan.*\(' | grep -v 'dsldevice.lan' | cut -d' ' -f5 | awk '{$1=$1};1')

if [ $? -eq 0 ]; then
    echo "Hostname command ran successfully"
else
    exit 1
fi

for i in "${!arry[@]}"; do printf "%s\t%s\n" "${arry[i]}" "${arry2[i]}" >> ${DOCKER_DIR}hosts; done

cat ${DOCKER_DIR}hosts > /etc/hosts
