#!/bin/bash -x

head="[${MODULE_NAME}-pipeline-deploy] "

[ -z $PIPELINEDIR ] && export PIPELINEDIR=.pipeline

. $PIPELINEDIR/.colors
. $PIPELINEDIR/.pipeline_aliases

npmlogin cache

cdir=$(pwd)
log info "${iyellow}$head${nc}called with stage: $STAGE, ACCOUNT_ID: $ACCOUNT_ID, REGION: $REGION${nc}"

if [ -z $STAGE ]; then
	log error "${ired}$head${nc}STAGE environment variable is not define${nc}"

	exit 1
fi

export SLS_DEBUG=*
log info "${iyellow}$head${nc}going to deploy from $PIPELINEDIR${nc}"

issls=`which sls`
if [ $? -ne 0 ]; then
	log info "${iyellow}$head${nc}sls is not installed, run npm install -g serverless${nc}"
	(cd $PIPELINEDIR; npm install -g serverless@2.29.0)
fi

(cd $PIPELINEDIR; sls deploy --stage $STAGE --region $REGION)
if [ $? -ne 0 ]; then
	log error "${ired}$head${nc}failed running deploy on stage $STAGE${nc}"

	exit 1
fi

log info "${iyellow}$head completed running deploy $PIPELINEDIR/lambda with exist zero code"
cd $cdir

exit 0
