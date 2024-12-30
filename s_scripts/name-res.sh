#!/usr/bin/env bash

HDFS_DATANODE_USER=root
HDFS_DATANODE_SECURE_USER=hdfs
HDFS_NAMENODE_USER=root
HDFS_SECONDARYNAMENODE_USER=root

ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
ssh-keygen -t rsa -f /etc/ssh/ssh_host_dsa_key -N ''
ssh-keygen -t rsa -f /etc/ssh/ssh_host_ed25519_key -N ''
/usr/sbin/sshd

source ~/.bashrc

# Airflow Worker
# timeout 20 airflow celery worker -l=/root/logs/airflow/worker/worker.log --stderr=/root/logs/airflow/worker/worker.err --stdout=/root/logs/airflow/worker/worker.out --pid=/run/airflow/airflow-worker.pid -D

HADOOP_HDFS_HOME=${DOCKER_DIR}hadoop

# NameNode
# if [ ! -f ${DOCKER_DIR}${LOCAL_NAMENODE_DIR}/current ]; then
# 	echo "Namenode Format"
# 	"${HADOOP_HDFS_HOME}/bin/hdfs" --daemon start journalnode
# 	"${HADOOP_HDFS_HOME}/bin/hdfs" namenode -format -clusterid "hbdc"
# 	"${HADOOP_HDFS_HOME}/bin/hdfs" namenode -initializeSharedEdits -force
# 	"${HADOOP_HDFS_HOME}/bin/hdfs" namenode -bootstrapStandby
# 	"${HADOOP_HDFS_HOME}/bin/hdfs" namenode &
# else
# 	echo "Checkpoint recovery"
# 	"${HADOOP_HDFS_HOME}/bin/hdfs" namenode --importCheckpoint &
# 	if [ $? -ne 0 ]; then
# 		"${HADOOP_HDFS_HOME}/bin/hdfs" --daemon start journalnode
# 		echo "Manual recovery"
# 		"${HADOOP_HDFS_HOME}/bin/hdfs" namenode -bootstrapStandby
# 		"${HADOOP_HDFS_HOME}/bin/hdfs" --daemon start namenode &
# 	fi
# fi

"${HADOOP_HDFS_HOME}/bin/hdfs" --daemon start journalnode
"${HADOOP_HDFS_HOME}/bin/hdfs" --daemon start httpfs

if [ "$(hostname)" == "name-res1.bdc.home" ] && [ ! -d ${DOCKER_DIR}${LOCAL_NAMENODE_DIR}/current ]; then
	echo "New Cluster Setup"
	"${HADOOP_HDFS_HOME}/bin/hdfs" namenode -format -force -clusterid "hbdc"
	"${HADOOP_HDFS_HOME}/bin/hdfs" namenode -initializeSharedEdits -force
	"${HADOOP_HDFS_HOME}/bin/hdfs" zkfc -formatZK -force
else
	echo "General Setup"
	"${HADOOP_HDFS_HOME}/bin/hdfs" namenode -bootstrapStandby
fi

"${HADOOP_HDFS_HOME}/bin/hdfs" zkfc -formatZK -force
"${HADOOP_HDFS_HOME}/bin/hdfs" zkfc -formatZK -force
"${HADOOP_HDFS_HOME}/bin/hdfs" namenode &


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
