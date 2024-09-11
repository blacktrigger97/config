#!/bin/sh

source /root/.profile

cd /root

rm -rf config

gh repo clone blacktrigger97/config

rsync -avru config/hadoop/ hadoop

rsync -avru config/spark/ spark