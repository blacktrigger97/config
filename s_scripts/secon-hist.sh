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

source ~/.bashrc

## @description  usage info
## @audience     private
## @stability    evolving
## @replaceable  no 

sh /root/s_scripts/host-config.sh

(crontab -l 2>/dev/null; echo "*/2 * * * * /root/s_scripts/host-config.sh >/dev/null 2>&1") | crontab - 

HADOOP_HDFS_HOME=${DOCKER_DIR}hadoop

# Secondary NameNode
if [[ "$(hostname)" != "secon-hist" ]]; then
	echo "Secondary Namenode is already up"
else
	rm -rf ${DOCKER_DIR}${DOCKER_SECONDARY_NAMENODE_DIR}/*
	"${HADOOP_HDFS_HOME}/bin/hdfs"  secondarynamenode &
	echo "Secondary namenode initiated"
fi

sleep 10

# Job History Server
if [[ "$(hostname)" != "secon-hist" ]]; then
   echo "JobHistory is already up"
else
   "${HADOOP_HDFS_HOME}/bin/mapred"  historyserver &
   echo "JobHistory in initiated"
fi

sleep 120

mysql -phive -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='hive_metastore'" > mysql_tst.log

hive_db=`head -1 mysql_tst.log | awk '{print $1;}'`

if [[ "$hive_db" == "hive_metastore" ]];
then
  echo "DATABASE ALREADY EXISTS"
else
  echo "DATABASE DOES NOT EXIST, CREATING HIVE_METASTORE"
  #hive_merastore creation
  ${DOCKER_DIR}hive/bin/schematool -dbType mysql -initSchema --verbose
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

while ! "${HADOOP_HDFS_HOME}/bin/hdfs" dfs -test -d /root/spark/logs; do continue; done

start-history-server.sh

#sleep 10

#$HIVE_HOME/bin/hive --service metastore &

#sleep 10

#$HIVE_HOME/bin/hive --service hiveserver2 &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?


#---------------------------------------------------------
# eof
