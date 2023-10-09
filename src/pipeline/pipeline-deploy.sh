#!/usr/bin/env bash

head="[${MODULE_NAME}-pipeline-deploy] "

[ -z $PIPELINEDIR ] && export PIPELINEDIR=.pipeline

. $PIPELINEDIR/.colors
. $PIPELINEDIR/.pipeline_aliases

cdir=$(pwd)

pushd $PIPELINEDIR
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
	npm install -g serverless@2.29.0
fi

for (( i = 0; i < ${#LAMBDA_SERVERLESSES[@]}; i++ ));
do		
	log info "${iyellow}${head}going to deploy $PIPELINEDIR/${LAMBDA_SERVERLESSES[$i]}${nc}"
	sls deploy --stage $STAGE --config ${LAMBDA_SERVERLESSES[$i]} --region $REGION
	if [ $? -ne 0 ]; then
		log error "${ired}$head${nc}failed running deploy on stage $STAGE${nc}"

		exit 1
	fi
	log info "${iyellow}$head${nc}lunch job for serverless ${iwhite}${LAMBDA_SERVERLESSES[$i]} $STAGE${nc}"
done	

# isFailed='no'
# for job in `jobs -p`
# do
#   wait $job
# 	if [ $? -ne 0 ]; then
# 		log error "${ired}$head${nc}failed running deploy on stage $STAGE${nc}"

# 		isFailed='yes'
# 	fi		
# done

# if [ X$isFailed == X'yes' ]; then
# 	log error "${ired}$head${nc}found one serveless failed, abort $STAGE${nc}"

# 	exit 1
# fi

log info "${iyellow}${head}successful deploy serverless ${LAMBDA_SERVERLESSES[$i]}${nc}"	

if [ -f serverless.yml ]; then	
	sls deploy --stage $STAGE --region $REGION
	if [ $? -ne 0 ]; then
		log error "${ired}$head${nc}failed running deploy on stage $STAGE${nc}"

		exit 1
	fi
fi

log info "${iyellow}${head}completed running deploy $PIPELINEDIR/lambda with exist zero code"
popd

# if [ "X"$LAMBDA_DOCS == "Xyes" -a -f $PIPELINEDIR/pipeline_docs.sh ]; then
# 	log info "${ired}$head${nc}LAMBDA_DOCS is yes, going to update swagger docs files${nc}"

# 	$PIPELINEDIR/pipeline_docs.sh
# fi

exit 0
