#!/usr/bin/env bash

head="[${MODULE_NAME}-pipeline-build] "

[ -z $PIPELINEDIR ] && export PIPELINEDIR=.pipeline

. $PIPELINEDIR/.colors
. $PIPELINEDIR/.pipeline_aliases

cdir=$(pwd)
log info "${iyellow}$head${nc}called with STAGE: $STAGE and TEST_ENV: $TEST_ENV"

if [ "X"$LAMBDA_IS_NEED_SRC = "Xno" ]; then
  log info "${iyellow}$head${nc}LAMBDA_IS_NEED_SRC is no, no need to compile $PIPELINEDIR/$LAMBDA_SRCDIR${nc}"  

  exit 0
fi

log info "${iyellow}$head${nc}going to compile $PIPELINEDIR/src${nc}"
(cd $PIPELINEDIR; npm run compile)
if [ $? -ne 0 ]; then
  log error "${ired}${head}failed compiling $PIPELINEDIR/src${nc}"

  exit 1
fi
log info "${iyellow}$head${nc}successful compile $PIPELINEDIR/src${nc}"

cd $cdir

exit 0

