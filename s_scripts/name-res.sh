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

source ~/.bashrc

HADOOP_HDFS_HOME=${DOCKER_DIR}hadoop

# Airflow Initialize Database
timeout 20 airflow db migrate

# Airflow Admin Creation
timeout 20 airflow users create -e blacktrigger97@gmail.com -f Airflow -l Admin -u admin -p admin_123 -r Admin

# Airflow Webserver
timeout 10 airflow webserver -l=/root/logs/airflow/webserver/webserver.log --stderr=/root/logs/airflow/webserver/webserver.err --stdout=/root/logs/airflow/webserver/webserver.out --pid=/run/airflow/airflow-webserver.pid -D

# Airflow Scheduler
timeout 10 airflow scheduler -l=/root/logs/airflow/scheduler/scheduler.log --stderr=/root/logs/airflow/scheduler/scheduler.err --stdout=/root/logs/airflow/scheduler/scheduler.out --pid=/run/airflow/airflow-scheduler.pid -D

# Airflow Flower
timeout 10 airflow celery flower -l=/root/logs/airflow/flower/flower.log --stderr=/root/logs/airflow/flower/flower.err --stdout=/root/logs/airflow/flower/flower.out --pid=/run/airflow/airflow-flower.pid -D

# NameNode
if [ ! -f ${DOCKER_DIR}${LOCAL_NAMENODE_DIR}/current ]; then
	echo "Namenode Format"
	"${HADOOP_HDFS_HOME}/bin/hdfs" namenode -format -force
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

# Airflow Triggerer
afl triggerer &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?


#---------------------------------------------------------
# eof
