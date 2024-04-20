#!/usr/bin/env bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Start hadoop dfs daemons.
# Optinally upgrade or rollback dfs state.
# Run this on master node.

## startup matrix:
#
# if $EUID != 0, then exec
# if $EUID =0 then
#    if hdfs_subcmd_user is defined, su to that user, exec
#    if hdfs_subcmd_user is not defined, error
#
# For secure daemons, this means both the secure and insecure env vars need to be
# defined.  e.g., HDFS_DATANODE_USER=root HDFS_DATANODE_SECURE_USER=hdfs
#
#echo "127.0.0.1    $(hostname)" >> /etc/hosts

HDFS_DATANODE_USER=root
HDFS_DATANODE_SECURE_USER=hdfs
HDFS_NAMENODE_USER=root
HDFS_SECONDARYNAMENODE_USER=root

ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
ssh-keygen -t rsa -f /etc/ssh/ssh_host_dsa_key -N ''
ssh-keygen -t rsa -f /etc/ssh/ssh_host_ed25519_key -N ''
/usr/sbin/sshd

#/usr/sbin/crond
## @description  usage info
## @audience     private
## @stability    evolving
## @replaceable  no

source ~/.bashrc

HADOOP_HDFS_HOME=${DOCKER_DIR}hadoop

#cp /etc/hosts ${DOCKER_DIR}hosts_bkp

#sh ${DOCKER_DIR}s_scripts/host-upd.sh

#(crontab -l 2>/dev/null; echo "*/2 * * * * ${DOCKER_DIR}s_scripts/host-upd.sh &> ${DOCKER_DIR}s_scripts/hosts.log") | crontab -

#sleep 60

rm -rf ${DOCKER_DIR}${DOCKER_DATANODE_DIR}/*

# Create neccessary directory if not exists
if [[ "$(hostname)" == "data-node1.bdc.home" ]]; then
	# DataNode
	echo "Starting $(hostname)"
	"${HADOOP_HDFS_HOME}/bin/hdfs" datanode &

	sleep 30

	"${HADOOP_HDFS_HOME}/bin/hdfs" dfs -test -d /root/spark
	if [ $? -eq 1 ]; then
		"${HADOOP_HDFS_HOME}/bin/hdfs" dfs -mkdir -p /user/root/nessie/warehouse
		"${HADOOP_HDFS_HOME}/bin/hdfs" dfs -mkdir -p /user/root/spark/jars
		"${HADOOP_HDFS_HOME}/bin/hdfs" dfs -put -f ${DOCKER_DIR}spark/jars/* /user/root/spark/jars/
		"${HADOOP_HDFS_HOME}/bin/hdfs" dfs -put -f ${DOCKER_DIR}spark/yarn/* /user/root/spark/jars/
		"${HADOOP_HDFS_HOME}/bin/hdfs" dfs -mkdir -p /user/root/spark/logs
		"${HADOOP_HDFS_HOME}/bin/hdfs" dfs -mkdir -p /tmp/datasets
		"${HADOOP_HDFS_HOME}/bin/hdfs" dfs -chmod -R 777 /
	fi
else
	echo "Data-Node 1 already up. Starting $(hostname)"
	sleep 60
	"${HADOOP_HDFS_HOME}/bin/hdfs"  datanode &
fi

"${HADOOP_HDFS_HOME}/bin/yarn"  nodemanager &


# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?


#---------------------------------------------------------
# eof
