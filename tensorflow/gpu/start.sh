#!/bin/bash
############################################################
# filename: start.sh
#
# TensorFlow Docker Container start script
# (C) Tasuku Hori, 2017 all rights reserved.
############################################################

## env script path
ENV_PATH=./env.sh

## operations
source ${ENV_PATH}

PID=`${CAT} ${PID_FILE}`

${DOCKER} start ${PID}