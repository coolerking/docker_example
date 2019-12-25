#!/bin/bash
############################################################
# filename: drop.sh
#
# TensorFlow Docker Container stop and drop script
#
############################################################

## env script path
ENV_PATH=./env.sh

## operations
source ${ENV_PATH}

PID=`${CAT} ${PID_FILE}`

${DOCKER} stop ${PID}
${DOCKER} rm ${PID}

${RM} -rf ${PID_FILE}