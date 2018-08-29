#!/bin/sh

STATUS_CODE=`curl -o /dev/null -s -w %{http_code} "http://127.0.0.1:22022/actuator/health"`
if [ ${STATUS_CODE} -ne 200 ]
then
    exit 1
else
    exit 0
fi