#!/usr/bin/env bash

source ~/.profile

# Airflow Initialize Database
airflow db migrate 

# Airflow Admin Creation
# airflow users create -e blacktrigger97@gmail.com -f Airflow -l Admin -u admin -p admin_123 -r Admin

# Airflow Webserver
airflow api-server -l=/root/logs/airflow/webserver/webserver.log --stderr=/root/logs/airflow/webserver/webserver.err --stdout=/root/logs/airflow/webserver/webserver.out --pid=/run/airflow/airflow-webserver.pid &

# Airflow Scheduler
airflow scheduler -l=/root/logs/airflow/scheduler/scheduler.log --stderr=/root/logs/airflow/scheduler/scheduler.err --stdout=/root/logs/airflow/scheduler/scheduler.out --pid=/run/airflow/airflow-scheduler.pid &

# Airflow Triggerer
airflow triggerer -l=/root/logs/airflow/triggerer/triggerer.log --stderr=/root/logs/airflow/triggerer/triggerer.err --stdout=/root/logs/airflow/triggerer/triggerer.out --pid=/run/airflow/airflow-triggerer.pid &

# Airflow Flower
# celery flower --address='airflow.bdc.home' -l=/root/logs/airflow/flower/flower.log --stderr=/root/logs/airflow/flower/flower.err --stdout=/root/logs/airflow/flower/flower.out --pid=/run/airflow/airflow-flower.pid &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?
