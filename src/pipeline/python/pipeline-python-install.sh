#!/bin/bash -x

head="[${MODULE_NAME}-pipeline-install]"

[ -z $PIPELINEDIR ] && export PIPELINEDIR=.pipeline

. $PIPELINEDIR/.colors
. $PIPELINEDIR/.pipeline_aliases
npmlogin cache

cdir=$(pwd)
log info "${iyellow}$head${nc} called with STAGE: $STAGE and ACCOUNT_ID: $ACCOUNT_ID"

for item in "${LAMBDA_SRCLIST[@]}"
do
	cp -r $item $PIPELINEDIR	
	log info "${iyellow}${head} copy ${white}$item${iyellow} --> $PIPELINEDIR${nc}"	
done

# Set NPM private registry - ToDO - will need to fix its location in the future.

pushd $PIPELINEDIR;

echo "before installing python version"
$PYTHON_BIN --version

issls=`which sls`
if [ $? -ne 0 ]; then	
	SKIP_PYTHON_VERSION="no"
	log info "${iyellow}$head${nc} going to install python3${nc}"

	apt-get update && apt-get install -y software-properties-common
	apt-get install -y $PYTHON_VERSION python3-venv python3-pip  
	# apt-get update && apt-get install -y $PYTHON_VERSION python3-venv python3-pip	
fi

echo "after installing python version"
$PYTHON_BIN --version

if [ ! -d venv ]; then
	pip3 install virtualenv 
  $PYTHON_BIN -m venv venv
	# virtualenv venv
fi
source venv/bin/activate

AWS=aws

CUSTOM_PROFILE=
if [ "X"$WITH_AWS_PROFILE != "X" ]; then 
	CUSTOM_PROFILE="--profile $WITH_AWS_PROFILE"  
	log info "${iyellow}$head${nc} CUSTOM_PROFILE: $CUSTOM_PROFILE ${nc}"
fi

log info "${iyellow}$head${nc} going to login to geospatial-pypi-cache${nc}"
$AWS codeartifact login --tool pip --repository geospatial-pypi-cache --domain intel-geospatial --domain-owner 908240026853 $CUSTOM_PROFILE

if [ $? -ne 0 ]; then
  log error "${ired}$head${nc} unable to aws login to geospatial-pypi-cache${nc}"

  exit 1
fi

log info "${iyellow}$head${nc} going to npm install $PIPELINEDIR${nc}"
npm install

if [ X$LAYER_IS_NEED = Xyes  ]; then
	log info "${iyellow}$head${nc} going to install layer $PIPELINEDIR/$LAYER_INSTALL_DIR"
	
	if [ -d $LAYER_INSTALL_DIR ]; then
		rm -rf $LAYER_INSTALL_DIR
	fi
	mkdir -p $LAYER_INSTALL_DIR

  cp requirements.txt $LAYER_INSTALL_DIR
  (cd $LAYER_INSTALL_DIR; pip3 install -t python/lib/${PYTHON_VERSION}/site-packages -r requirements.txt)    
  
	if [ $? -ne 0 ]; then
		log error "${ired}${head} pip3 install failed ${LAYER_INSTALL_DIR}${nc}"		
				
		exit 1
  fi		
  popd

	log info "${iyellow}$head${nc} completed install layer $PIPELINEDIR/$LAYER_INSTALL_DIR"	  
fi	

exit 0
