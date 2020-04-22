#!/bin/sh

IN_FILE=$1
echo ${IN_FILE} | grep -i "csv"
if [[ $? -eq 0 ]]; then
   echo "OK"
fi