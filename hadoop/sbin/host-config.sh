#!/usr/bin/env bash
#
#
cat /etc/hosts | grep -E $(hostname)*
if [ $? -eq 1 ]; then
	echo "Adding host eth0 IP in hosts file"
	ip_addr=`/usr/sbin/ifconfig eth0 | grep 'inet ' | awk '{print $2}'`
	echo "$ip_addr    $(hostname)" >> /etc/hosts
fi

IFS=$'\n' read -r -d '' -a hdc_addr < <(cat ${DOCKER_DIR}hosts/hosts | awk '{print $2}')
for i in ${hdc_addr[@]}
do
	cat ${DOCKER_DIR}hosts/hosts | grep -E $i >> /etc/hosts
done

cat ${DOCKER_DIR}hosts/hosts | grep -E $(hostname)*
if [ $? -eq 1 ]; then
        echo "Adding host eth0 IP in hosts file"
        ip_addr=`/usr/sbin/ifconfig eth0 | grep 'inet ' | awk '{print $2}'`
        echo "$ip_addr    $(hostname)" >> ${DOCKER_DIR}hosts/hosts
fi

'''name_addr=`cat ${DOCKER_DIR}/hosts/hosts | awk '{print $2}'`
for i in "$name_addr[@]"
do
	if [[ "$i" == "$(hostname)" ]]; then
		continue
	else
		echo "Adding other namen9ode eth0 IP in hosts file"
		i_addr=`cat ${LOCAL_DIR}/hosts | grep -E "$i" >> /etc/hosts`
	fi
done

data_addr=`cat ${LOCAL_DIR}/hosts | grep -E name-*`
for j in "$data_addr[@]"
do
        if [[ "$j" == "$(hostname)" ]]; then
                continue
        else
		echo "Adding other data node eth0 IP in hosts file"
                i_addr=`cat ${LOCAL_DIR}/hosts | grep -E "$j" >> /etc/hosts`
        fi
done'''


