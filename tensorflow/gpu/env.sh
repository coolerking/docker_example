#!/bin/bash
############################################################
# filename: env.sh
#
# TensorFlow Docker Container configuration script
# This is used by start / stop script
# (C) Tasuku Hori, 2017 all rights reserved.
############################################################

## Jupyter notebook password

PASSWORD=admin123

## PORT

# Jyupiter port
JUP_PORT=8888
# TensorFlow Boad port
TFB_PORT=6006
# REST API port
REST_PORT=3000

## TensorFlow Version

TF_VER=1.3.0
#TF_VER=1.3.0-rc0
#TF_VER=1.2.1
#TF_VER=1.2.0
#TF_VER=1.1.0
#TF_VER=1.0.1

## CPU / GPU

# CPU
#NODE=
#DOCKER=/usr/bin/docker

# GPU
NODE=-gpu
DOCKER=/usr/bin/nvidia-docker

## Python Version

# 2.x
#PY_VER=

#  3.x
PY_VER=-py3

## syslog server

SYSLOG_HOST=160.14.101.70
SYSLOG_PORT=514

## docker image

DOCKER_IMAGE=tensorflow/tensorflow

## docker tag

#DOCKER_TAG=latest
DOCKER_TAG=${TF_VER}${NODE}${PY_VER}

## pid file path
BASE_DIR=${HOME}/tensorflow

PID_DIR=${BASE_DIR}/pid
#PID_DIR=.
PID_FILE=${PID_DIR}/${JUP_PORT}_${DOCKER_TAG}.pid

## bin path
# ubuntu
CAT=/bin/cat
RM=/bin/rm
# cent
#CAT=/usr/bin/cat
#RM=/usr/bin/rm

## work / share directory path
WORK_DIR=${BASE_DIR}/gpu/work
SHARE_DIR=${BASE_DIR}/share

## operations
PREFIX=WORKING_VERSION_IS_
${RM} -rf ${WORK_DIR}/${PREFIX}*
echo "${PREFIX}${DOCKER_TAG}" > ${WORK_DIR}/${PREFIX}${DOCKER_TAG}
