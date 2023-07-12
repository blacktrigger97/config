#!/usr/bin/env bash
#
#
source ~/.bashrc

service cron reload

ip_addr=`ifconfig eth0 | grep 'inet ' | awk '{print $2}'`

cat /etc/hosts | grep -E $(hostname)*
if [ $? -eq 1 ]; then
	echo "Adding host eth0 IP in hosts file"
	echo "$ip_addr    $(hostname)" >> /etc/hosts
fi

IFS=$'\n' read -r -d '' -a host_addr < <(cat /etc/hosts | awk '{print $2}')
IFS=$'\n' read -r -d '' -a hdc_addr < <(cat ${DOCKER_DIR}hosts/hosts | awk '{print $2}')
for i in ${hdc_addr[@]}
do
	echo $i
	if [[ "$i" == "$(hostname)" ]]; then
		echo "Updating shared hosts file"
		sed -i -E "s/.*$(hostname)/$ip_addr\t$(hostname)/g" ${DOCKER_DIR}hosts/hosts
	else
		if [[ ! " ${host_addr[*]} " =~ " $i " ]]; then
			echo "Adding other node to hosts file"
			cat ${DOCKER_DIR}hosts/hosts | grep -E $i >> /etc/hosts
		else
			echo "Updating hosts file"
			upd_addr=`cat ${DOCKER_DIR}hosts/hosts | grep -E $i | awk '{print $1}'`
			cp /etc/hosts ~/hosts.new
			sed -i -E "s/.*$i/$upd_addr\t$i/g" ~/hosts.new
			cp -f ~/hosts.new /etc/hosts
		fi
	fi
done


if [[ ! " ${hdc_addr[*]} " =~ " $(hostname) " ]]; then
    	# whatever you want to do when array doesn't contain value
	echo "$ip_addr    $(hostname)" >> ${DOCKER_DIR}hosts/hosts
fi

