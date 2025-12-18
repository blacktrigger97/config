#!/usr/bin/env bash

# source ~/.profile

# uv package download
# cd /opt/airflow
# uv pip install --system -r pyproject.toml

host=`hostname`
# Airflow Worker
airflow celery worker -H $host -l=/opt/airflow/logs/worker/worker.log --stderr=/opt/airflow/logs/worker/worker.err --stdout=/opt/airflow/logs/worker/worker.out --pid=/run/airflow/airflow-worker.pid &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?
