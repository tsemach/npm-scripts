#!/usr/bin/env bash

head="[${MODULE_NAME}-pipeline-clean] "

[ -z $PIPELINEDIR ] && export PIPELINEDIR=.pipeline

. $PIPELINEDIR/.colors
. $PIPELINEDIR/.pipeline_aliases

log info "${iyellow}$head${nc}called with STAGE: $STAGE and ACCOUNT_ID: $ACCOUNT_ID"
for item in "${LAMBDA_CLEANLIST[@]}"
do
	if [ -e $PIPELINEDIR/$item ]; then
		rm -rf $PIPELINEDIR/$item
		log info "${iyellow}${head}remove ${white}$PIPELINEDIR/$item${iyellow}${nc}"	
	fi
done

# clean serverless files
for (( i = 0; i < ${#LAMBDA_SERVERLESSES[@]}; i++ ));
do
	if [ -f $PIPELINEDIR/${LAMBDA_SERVERLESSES[$i]} ]; then
		rm -f $PIPELINEDIR/${LAMBDA_SERVERLESSES[$i]}
		log info "${iyellow}${head}remove ${white}${LAMBDA_SERVERLESSES[$i]}${iyellow} --> $PIPELINEDIR${nc}"	
	fi
done	

if [ -f $PIPELINEDIR/serverless.yml ]; then
	rm -f $PIPELINEDIR/serverless.yml
	log info "${iyellow}${head}remove ${white}$PIPELINEDIR/serverless.yml${iyellow} --> $PIPELINEDIR${nc}"	
fi
# fi

log info  "${iyellow}$head${nc}successful complete running $PIPELINEDIR/pipeline_install.sh with STAGE: $STAGE"

exit 0



