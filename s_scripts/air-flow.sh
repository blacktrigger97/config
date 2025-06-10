#!/usr/bin/env bash

source ~/.profile

# uv package download
uv pip install --system /root/airflow/pyproject.toml

sleep 600
# # Airflow Initialize Database
# airflow db migrate 

# # Airflow Admin Creation
# # airflow users create -e blacktrigger97@gmail.com -f Airflow -l Admin -u admin -p admin_123 -r Admin

# # Airflow Webserver
# airflow api-server -l=/root/airflow/logs/api-server/api-server.log --stderr=/root/airflow/logs/api-server/api-server.err --stdout=/root/airflow/logs/api-server/api-server.out --pid=/run/airflow/airflow-server.pid &

# # Airflow Scheduler
# airflow scheduler -l=/root/airflow/logs/scheduler/scheduler.log --stderr=/root/airflow/logs/scheduler/scheduler.err --stdout=/root/airflow/logs/scheduler/scheduler.out --pid=/run/airflow/airflow-scheduler.pid &

# # Airflow Triggerer
# airflow dag-processor -l=/root/airflow/logs/dag_processor/dag_processor.log --stderr=/root/airflow/logs/dag_processor/dag_processor.err --stdout=/root/airflow/logs/dag_processor/dag_processor.out --pid=/run/airflow/airflow-dagprocessor.pid &

# # Airflow Triggerer
# airflow triggerer -l=/root/airflow/logs/triggerer/triggerer.log --stderr=/root/airflow/logs/triggerer/triggerer.err --stdout=/root/airflow/logs/triggerer/triggerer.out --pid=/run/airflow/airflow-triggerer.pid &

# # Airflow Flower
# airflow celery flower --hostname='airflow.bdc.home' -l=/root/airflow/logs/flower/flower.log --stderr=/root/airflow/logs/flower/flower.err --stdout=/root/airflow/logs/flower/flower.out --pid=/run/airflow/airflow-flower.pid &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?
