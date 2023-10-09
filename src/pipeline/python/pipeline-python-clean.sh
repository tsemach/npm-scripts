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

log info  "${iyellow}$head${nc}successful complete running $PIPELINEDIR/pipeline_install.sh with STAGE: $STAGE"

exit 0



