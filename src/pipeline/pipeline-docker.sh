#!/usr/bin/env bash

head="[${MODULE_NAME}-pipeline-docker]"

[ -z $PIPELINEDIR ] && export PIPELINEDIR=.pipeline

. $PIPELINEDIR/.colors
. $PIPELINEDIR/.pipeline_aliases
. $PIPELINEDIR/.pipeline_exports

docker --version

if [ $? -ne 0 ]; then
  log info "${iyellow}$head${nc} docker is NOT exist going to install${nc}"  
  apt-get update 
  apt-get install -y apt-utils apt-transport-https ca-certificates curl gnupg lsb-release systemd software-properties-common jq

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic test"

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io
  service start docker
else
  log info "${iyellow}$head${nc} docker is exist not need to install${nc}"  
fi

pushd $PIPELINEDIR

if [ "X"$ECR_REGISTRY_NAME != "X" ]; then
  log info "${iyellow}$head${nc} going to check if ECR_REGISTRY_NAME: $ECR_REGISTRY_NAME exist"  
    
  export registryARN=`aws ecr describe-repositories | jq -r '.repositories[].repositoryArn' | grep repository/$ECR_REGISTRY_NAME`
  ret=$?
  log info "${iyellow}$head${nc} registryARN: $registryARN"

  if [ $ret -ne 0 ]; then
    log info "${iyellow}$head${nc} gvdl/aiwo/ai-feedback registry is not exist going to create one${nc}"
  
    aws ecr create-repository --repository-name $ECR_REGISTRY_NAME
  else
    log info "${iyellow}$head${nc} found registry ${iyellow}arn:aws:ecr:${REGION}:$ACCOUNT_ID:repository/${ECR_REGISTRY_NAME}${nc} exist${nc}"  
  fi
else
  log info "${iyellow}$head${nc} ECR_REGISTRY_NAME is not define, skip registry check${nc}"  
fi

log info "${iyellow}$head${nc} called with stage: $STAGE, ACCOUNT_ID: $ACCOUNT_ID, REGION: $REGION, image: $DOCKER_IMAGE_NAME ${nc}"

log info "${iyellow}$head${nc} going to loging to ecr on ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com ${nc}"
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

cwd=`pwd`
log info "${iyellow}$head${nc} buildling the image ${DOCKER_IMAGE_NAME} from pwd: $cwd ${nc}"
docker build -t $DOCKER_IMAGE_NAME .
if [ $? -ne 0 ]; then
  log error "${ired}$head${nc} fail on docker build $DOCKER_IMAGE_NAME${nc}"

  exit 1
fi

log info "${iyellow}$head${nc} tagging on aws ecr${nc}"
docker tag ${DOCKER_IMAGE_NAME}:latest ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${DOCKER_IMAGE_NAME}:latest
if [ $? -ne 0 ]; then
  log error "${ired}$head${nc} fail on docker tag ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${DOCKER_IMAGE_NAME}:latest${nc}"

  exit 1
fi

log info "${iyellow}$head${nc} pushing to aws ecr: ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${DOCKER_IMAGE_NAME}:latest ${nc}"
docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${DOCKER_IMAGE_NAME}:latest
if [ $? -ne 0 ]; then
  log error "${ired}$head${nc} fail on docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${DOCKER_IMAGE_NAME}:latest${nc}"

  exit 1
fi

log info "${iyellow}${head} completed running docker build and deploy docker ${DOCKER_IMAGE_NAME} ${nc}"

popd

exit 0
