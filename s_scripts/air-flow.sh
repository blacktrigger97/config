#!/usr/bin/env bash

source ~/.profile

# Airflow Initialize Database
airflow db migrate 

# Airflow Admin Creation
# airflow users create -e blacktrigger97@gmail.com -f Airflow -l Admin -u admin -p admin_123 -r Admin

# Airflow Webserver
airflow api-server -l=/root/logs/airflow/api-server/api-server.log --stderr=/root/logs/airflow/api-server/api-server.err --stdout=/root/logs/airflow/api-server/api-server.out --pid=/run/airflow/airflow-server.pid &

# Airflow Scheduler
airflow scheduler -l=/root/logs/airflow/scheduler/scheduler.log --stderr=/root/logs/airflow/scheduler/scheduler.err --stdout=/root/logs/airflow/scheduler/scheduler.out --pid=/run/airflow/airflow-scheduler.pid -D

# Airflow Triggerer
airflow dag-processor -l=/root/logs/airflow/dag_processor/dag_processor.log --stderr=/root/logs/airflow/dag_processor/dag_processor.err --stdout=/root/logs/airflow/dag_processor/dag_processor.out --pid=/run/airflow/airflow-dagprocessor.pid -D

# Airflow Triggerer
airflow triggerer -l=/root/logs/airflow/triggerer/triggerer.log --stderr=/root/logs/airflow/triggerer/triggerer.err --stdout=/root/logs/airflow/triggerer/triggerer.out --pid=/run/airflow/airflow-triggerer.pid &

# Airflow Flower
# celery flower --address='airflow.bdc.home' -l=/root/logs/airflow/flower/flower.log --stderr=/root/logs/airflow/flower/flower.err --stdout=/root/logs/airflow/flower/flower.out --pid=/run/airflow/airflow-flower.pid &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?
