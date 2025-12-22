#!/usr/bin/env bash

source ~/.profile

# uv package download
# cd /opt/airflow
# uv pip install --system -r pyproject.toml

chmod 777 /opt/airflow/password.json

# sleep 600
# Airflow Initialize Database
airflow db migrate

# Airflow Admin Creation
# airflow users create -e blacktrigger97@gmail.com -f Airflow -l Admin -u admin -p admin_123 -r Admin

# Airflow Api Server
airflow api-server -H `hostname` -l=/opt/airflow/logs/api-server/api-server.log --stderr=/opt/airflow/logs/api-server/api-server.err --stdout=/opt/airflow/logs/api-server/api-server.out --pid=/run/airflow/airflow-server.pid &

# Airflow Scheduler
airflow scheduler -l=/opt/airflow/logs/scheduler/scheduler.log --stderr=/opt/airflow/logs/scheduler/scheduler.err --stdout=/opt/airflow/logs/scheduler/scheduler.out --pid=/run/airflow/airflow-scheduler.pid &

# Airflow Dag Processor
airflow dag-processor -l=/opt/airflow/logs/dag_processor/dag_processor.log --stderr=/opt/airflow/logs/dag_processor/dag_processor.err --stdout=/opt/airflow/logs/dag_processor/dag_processor.out --pid=/run/airflow/airflow-dagprocessor.pid &

# Airflow Triggerer
airflow triggerer -H `hostname` -l=/opt/airflow/logs/triggerer/triggerer.log --stderr=/opt/airflow/logs/triggerer/triggerer.err --stdout=/opt/airflow/logs/triggerer/triggerer.out --pid=/run/airflow/airflow-triggerer.pid &

# Airflow Flower
airflow celery flower --hostname `hostname` -l=/opt/airflow/logs/flower/flower.log --stderr=/opt/airflow/logs/flower/flower.err --stdout=/opt/airflow/logs/flower/flower.out --pid=/run/airflow/airflow-flower.pid &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?
