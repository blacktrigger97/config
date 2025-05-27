#!/bin/sh

sed -i s/#http/http/g /etc/apk/repositories

apk add openssh rsync curl bind-tools docker docker-cli-compose git github-cli

rc-update add sshd boot

rc-service sshd start

< /dev/zero ssh-keygen -q -N ''

rc-update add docker boot

rc-service docker start

touch /root/.profile

cd /root

gh auth login

rm -rf Infra config hadoop spark

gh repo clone blacktrigger97/Infra

gh repo clone blacktrigger97/config

HDC_VERSION=`grep -E "^HDC_VERSION" Infra/.env | cut -d '=' -f2`
echo $HDC_VERSION

SCALA_VERSION=`grep -E "^SCALA_VERSION" Infra/.env | cut -d '=' -f2`
echo $SCALA_VERSION

wget https://downloads.apache.org/hadoop/common/hadoop-${HDC_VERSION}/hadoop-${HDC_VERSION}.tar.gz

tar -zxf hadoop-${HDC_VERSION}.tar.gz && rm hadoop-${HDC_VERSION}.tar.gz

mv hadoop-${HDC_VERSION} hadoop

SPARK_VERSION=`grep -E "^SPARK_VERSION" Infra/.env | cut -d '=' -f2`
echo $SPARK_VERSION

wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz

tar -zxf spark-${SPARK_VERSION}-bin-hadoop3.tgz && rm spark-${SPARK_VERSION}-bin-hadoop3.tgz

mv spark-${SPARK_VERSION}-bin-hadoop3 spark

ICEBERG_VER=`grep -E "^ICEBERG_VER" Infra/.env | cut -d '=' -f2`
echo $ICEBERG_VER

ICEBERG_SPARK_VER=`grep -E "^ICEBERG_SPARK_VER" Infra/.env | cut -d '=' -f2`
echo $ICEBERG_SPARK_VER

wget https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-${ICEBERG_SPARK_VER}_${SCALA_VERSION}/${ICEBERG_VER}/iceberg-spark-runtime-${ICEBERG_SPARK_VER}_${SCALA_VERSION}-${ICEBERG_VER}.jar -P spark/jars/

NESSIE_VER=`grep -E "^NESSIE_VER" Infra/.env | cut -d '=' -f2`
echo $NESSIE_VER

NESSIE_SPARK_VER=`grep -E "^NESSIE_SPARK_VER" Infra/.env | cut -d '=' -f2`
echo $NESSIE_SPARK_VER

wget https://repo.maven.apache.org/maven2/org/projectnessie/nessie-integrations/nessie-spark-extensions-${NESSIE_SPARK_VER}_${SCALA_VERSION}/${NESSIE_VER}/nessie-spark-extensions-${NESSIE_SPARK_VER}_${SCALA_VERSION}-${NESSIE_VER}.jar -P spark/jars/

SPARK_SQL_KAFKA_VER=`grep -E "^SPARK_SQL_KAFKA_VER" Infra/.env | cut -d '=' -f2`
echo $SPARK_SQL_KAFKA_VER

wget https://repo1.maven.org/maven2/org/apache/spark/spark-sql-kafka-${SPARK_SQL_KAFKA_VER}_${SCALA_VERSION}/${SPARK_VERSION}/spark-sql-kafka-${SPARK_SQL_KAFKA_VER}_${SCALA_VERSION}-${SPARK_VERSION}.jar -P spark/jars/

COMMON_POOL_VER=`grep -E "^COMMON_POOL_VER" Infra/.env | cut -d '=' -f2`
echo $COMMON_POOL_VER

wget https://repo1.maven.org/maven2/org/apache/commons/commons-pool2/${COMMON_POOL_VER}/commons-pool2-${COMMON_POOL_VER}.jar -P spark/jars/

KAFKA_CLIENT_VER=`grep -E "^KAFKA_CLIENT_VER" Infra/.env | cut -d '=' -f2`
echo $KAFKA_CLIENT_VER

wget https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/${KAFKA_CLIENT_VER}/kafka-clients-${KAFKA_CLIENT_VER}.jar -P spark/jars/

wget https://repo1.maven.org/maven2/org/apache/spark/spark-token-provider-kafka-${SPARK_SQL_KAFKA_VER}_${SCALA_VERSION}/${SPARK_VERSION}/spark-token-provider-kafka-${SPARK_SQL_KAFKA_VER}_${SCALA_VERSION}-${SPARK_VERSION}.jar -P spark/jars/

wget https://repo1.maven.org/maven2/org/apache/spark/spark-avro_${SCALA_VERSION}/${SPARK_VERSION}/spark-avro_${SCALA_VERSION}-${SPARK_VERSION}.jar -P spark/jars/

echo "export JAVA_HOME=/usr/lib/jvm/zulu11/" >> hadoop/etc/hadoop/hadoop-env.sh

mv spark/conf/spark-defaults.conf.template spark/conf/spark-defaults.conf

mv spark/conf/spark-env.sh.template spark/conf/spark-env.sh

echo "export HADOOP_CONF_DIR=/root/hadoop/etc/hadoop" >> spark/conf/spark-env.sh

rsync -avru config/hadoop/ hadoop

rsync -avru config/spark/ spark