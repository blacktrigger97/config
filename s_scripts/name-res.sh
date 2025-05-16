#!/usr/bin/env bash

ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
ssh-keygen -t rsa -f /etc/ssh/ssh_host_dsa_key -N ''
ssh-keygen -t rsa -f /etc/ssh/ssh_host_ed25519_key -N ''
/usr/sbin/sshd

source ~/.profile

# # Airflow Webserver
# afl webserver

# # Airflow Scheduler
# afl scheduler

# # Airflow Triggerer
# afl triggerer &

# # Airflow Flower
# aflc flower


HADOOP_HDFS_HOME=${DOCKER_DIR}hadoop

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

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?


#---------------------------------------------------------
# eof