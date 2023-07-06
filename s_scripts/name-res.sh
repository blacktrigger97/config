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

/usr/sbin/crond
## @description  usage info
## @audience     private
## @stability    evolving
## @replaceable  no

HADOOP_HDFS_HOME=/root/hadoop

source ~/.bashrc

touch ${DOCKER_DIR}hosts/hosts

(crontab -l 2>/dev/null; echo "*/2 * * * * /root/s_scripts/host-config.sh >/dev/null 2>&1") | crontab -

# NameNode
if [ ! -f /root/namenode/current ]; then
	echo "Namenode Format"
	/root/hadoop/bin/hdfs namenode -format -force
	"${HADOOP_HDFS_HOME}/bin/hdfs" namenode &
else
	echo "Checkpoint recovery"
	"${HADOOP_HDFS_HOME}/bin/hdfs" namenode --importCheckpoint &
	if [ $? -ne 0 ]; then
		echo "Manual recovery"
		"${HADOOP_HDFS_HOME}/bin/hdfs" namenode -recover &
	fi
fi

sleep 30

# Resource Manager
"${HADOOP_HDFS_HOME}/bin/yarn"  resourcemanager &
echo "Resource manager initiated"


# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?


#---------------------------------------------------------
# eof