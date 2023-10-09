#!/usr/bin/env bash

head="[${MODULE_NAME}-pipeline-install] "

[ -z $PIPELINEDIR ] && export PIPELINEDIR=.pipeline

. $PIPELINEDIR/.colors
. $PIPELINEDIR/.pipeline_aliases

cdir=$(pwd)
log info "${iyellow}$head${nc}called with STAGE: $STAGE and ACCOUNT_ID: $ACCOUNT_ID"

for item in "${LAMBDA_SRCLIST[@]}"
do
	cp -r $item $PIPELINEDIR	
	log info "${iyellow}${head}copy ${white}$item${iyellow} --> $PIPELINEDIR${nc}"	
done

for (( i = 0; i < ${#LAMBDA_SERVERLESSES[@]}; i++ ));
do
	cp ${LAMBDA_SERVERLESSES[$i]} $PIPELINEDIR	
	log info "${iyellow}${head}copy ${white}${LAMBDA_SERVERLESSES[$i]}${iyellow} --> $PIPELINEDIR${nc}"	
done	

npmlogin cache
if [ $? -ne 0 ]; then
	log info "${iyellow}$red${nc}failed npmlogin cache${nc}"

	exit 1
fi

if [ -f ./npmrc.tmp ]; then
	cat ./npmrc.tmp | grep -vi proxy > .npmrc
fi

if [ X$LAYER_IS_NEED = Xyes  ]; then
	log info "${iyellow}$head${nc}going to npm install $PIPELINEDIR/$LAYER_INSTALL_DIR"
		
	if [ -d $PIPELINEDIR/$LAYER_INSTALL_DIR ]; then
		rm -rf $PIPELINEDIR/$LAYER_INSTALL_DIR
	fi
	mkdir -p $PIPELINEDIR/$LAYER_INSTALL_DIR
	cp $PIPELINEDIR/package.json $PIPELINEDIR/$LAYER_INSTALL_DIR
	cp $PIPELINEDIR/package-lock.json $PIPELINEDIR/$LAYER_INSTALL_DIR

	(cd $PIPELINEDIR/$LAYER_INSTALL_DIR; npm ci --only=production)
	if [ $? -ne 0 ]; then
		log info "${iyellow}${head}npm ci --only=production failed try to run just npm install ${LAYER_INSTALL_DIR}${nc}"
		(cd $PIPELINEDIR/$LAYER_INSTALL_DIR; npm install --production)
		if [ $? -ne 0 ]; then
			log error "${ired}${head}failed running install on ${LAYER_INSTALL_DIR}${nc}"
				
			exit 1
		fi

		log info "${iyellow}${head}npm install pass ok${LAYER_INSTALL_DIR}${nc}"
	fi
	log info "${iyellow}$head${nc}completed install layer $PIPELINEDIR/$LAYER_INSTALL_DIR"	
fi	

log info "${iyellow}$head${nc}going to npm install $PIPELINEDIR${nc}"
(cd $PIPELINEDIR; npm install)
if [ $? -ne 0 ]; then
	log error "${ired}$head failed running install on $PIPELINEDIR${nc}"

	exit 1
fi
log info "${iyellow}$head${nc}completed npm install $PIPELINEDIR${nc}"
log info  "${iyellow}$head${nc}successful complete running $PIPELINEDIR/pipeline_install.sh with STAGE: $STAGE${nc}"

exit 0
