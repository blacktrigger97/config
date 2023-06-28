#!/usr/bin/env bash
#
#
cat /etc/hosts | grep -E $(hostname)*
if [ $? -eq 1 ]; then
	echo "Adding host eth0 IP in hosts file"
	ip_addr=`/usr/sbin/ifconfig eth0 | grep 'inet ' | awk '{print $2}'`
	echo "$ip_addr    $(hostname)" >> /etc/hosts
fi

name_addr=`cat ${LOCAL_DIR}/hosts | grep -E name-*`
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
done


