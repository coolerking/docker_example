#!/bin/bash
############################################################
# filename: stop.sh
#
# TensorFlow Docker Container stop script
#
############################################################

## env script path
ENV_PATH=./env.sh

## operations
source ${ENV_PATH}

PID=`${CAT} ${PID_FILE}`

${DOCKER} stop ${PID}
#${DOCKER} rm ${PID}

#${RM} -rf ${PID_FILE}