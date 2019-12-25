#!/bin/bash
############################################################
# filename: init.sh
#
# TensorFlow Docker Container create and start script
#
############################################################

## env script path
ENV_PATH=./env.sh

## operations
source ${ENV_PATH}

${DOCKER} run \
   --name "${DOCKER_TAG}" \
   --publish "${JUP_PORT}:8888" \
   --publish "${TFB_PORT}:6006" \
   --publish "${REST_PORT}:3000" \
   --dns 160.14.95.11 \
   --dns 160.14.23.11 \
   --dns 160.14.254.1 \
   --dns-search exa-corp.co.jp \
   --volume ${WORK_DIR}:/notebooks/work \
   --volume ${SHARE_DIR}:/notebooks/share \
   --env HTTP_PROXY="http://solidproxy.exa-corp.co.jp:8080/" \
   --env HTTPS_PROXY="http://solidproxy.exa-corp.co.jp:8080/" \
   --env NO_PROXY="localhost,127.0.0.1,*.exa-corp.co.jp,*.webpot.local,160.14.*,192.168.*,172.*" \
   --env PASSWORD="${PASSWORD}" \
   --log-driver=syslog \
   --log-opt syslog-address=tcp://${SYSLOG_HOST}:${SYSLOG_PORT} \
   --log-opt tag="${DOCKER_TAG}" \
   --detach \
   --cidfile ${PID_FILE} \
   ${DOCKER_IMAGE}:${DOCKER_TAG}
