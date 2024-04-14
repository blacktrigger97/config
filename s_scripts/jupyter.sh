#!/usr/bin/env bash
#
#
source ~/.bashrc

rm -f nohup.out

nohup pyspark &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?


#---------------------------------------------------------
# eof