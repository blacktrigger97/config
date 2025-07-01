#!/usr/bin/env bash

source ~/.profile

# uv package download
cd /root/airflow
uv pip install --system -r pyproject.toml

# Airflow Worker
airflow celery worker -H `hostname` -l=/root/airflow/logs/worker/worker.log --stderr=/root/airflow/logs/worker/worker.err --stdout=/root/airflow/logs/worker/worker.out --pid=/run/airflow/airflow-worker.pid &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?
