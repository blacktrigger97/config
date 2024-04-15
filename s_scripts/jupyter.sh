#!/usr/bin/env bash
#
#
source ~/.bashrc

rm -f nohup.out

nohup pyspark --master yarn --jars /root/spark/jars/iceberg-spark-runtime-3.4_2.12-1.5.0.jar,/root/spark/jars/nessie-spark-extensions-3.4_2.12-0.79.0.jar --conf spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions,org.projectnessie.spark.extensions.NessieSparkSessionExtensions --conf spark.sql.catalog.nessie=org.apache.iceberg.spark.SparkCatalog --conf spark.sql.catalog.nessie.uri=http://nessie.bdc.home:19120/api/v1 --conf spark.sql.catalog.nessie.ref=main --conf spark.sql.catalog.nessie.authentication.type=NONE --conf spark.sql.catalog.nessie.catalog-impl=org.apache.iceberg.nessie.NessieCatalog --conf spark.sql.catalog.nessie.warehouse=hdfs://name-res.bdc.home:9000/root/nessie/warehouse &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?


#---------------------------------------------------------
# eof
