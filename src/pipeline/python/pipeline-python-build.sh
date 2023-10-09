#!/usr/bin/env bash

head="[${MODULE_NAME}-pipeline-build]"

[ -z $PIPELINEDIR ] && export PIPELINEDIR=.pipeline

. $PIPELINEDIR/.colors
. $PIPELINEDIR/.pipeline_aliases

cdir=$(pwd)
log info "${iyellow}$head${nc} called with STAGE: $STAGE and TEST_ENV: $TEST_ENV"

exit 0
