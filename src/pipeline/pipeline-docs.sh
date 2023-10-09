#!/usr/bin/env bash

head="[${MODULE_NAME}-pipeline-docs] "

[ -z $PIPELINEDIR ] && export PIPELINEDIR=.pipeline

. $PIPELINEDIR/.colors
. $PIPELINEDIR/.pipeline_aliases

if [ "X"$LAMBDA_DOCS != "Xyes" ]; then
	log info "${iyellow}$head${nc}LAMBDA_DOCS is not equal to yes, skipping documentation on MODULE_NAME=$MODULE_NAME${bwhite}$GIT_REPO${nc}"

	exit 0
fi

pushd $PIPELINEDIR

if [ X$GIT_REPO != X ]; then
	log info "${iyellow}$head${nc}found pipeline running on code pipeline env, MODULE_NAME=$MODULE_NAME${bwhite}$GIT_REPO${nc}"

  git config --global credential.helper '!aws codecommit credential-helper $@'
  git config --global credential.UseHttpPath true

  export API_DOCS_TEMPDIR=$(mktemp -d -t api-docs-XXXXXXXXXX)  
  if [ "X"$API_DOCS_TEMPDIR == "X" -o ! -d $API_DOCS_TEMPDIR ]; then
    log error "${iyellow}$head${nc}unable to create $API_DOCS_TEMPDIR, abort${bwhite}$GIT_REPO${nc}"

    exit 0
  fi

  git clone codecommit://cicdgit@_api-docs $API_DOCS_TEMPDIR/_api-docs
  if [ $? -ne 0 ]; then
    log error "${iyellow}$head${nc}unable to clone codecommit://cicdgit@_api-docs${bwhite}$GIT_REPO${nc}"  

    exit 0
  fi

  cp ../docs/*.yaml $API_DOCS_TEMPDIR/_api-docs/$MODULE_NAME/

  log info "${iyellow}$head${nc}md5sum of local yaml docs files are:${bwhite}$GIT_REPO${nc}"
  md5sum ../docs/*

  cd $API_DOCS_TEMPDIR/_api-docs
  git commit -a -m "pipeline update $MODULE_NAME file"  
  git push  

  log info "${iyellow}$head${nc}md5sum of _api-docs yaml docs files are:${bwhite}$GIT_REPO${nc}"
  md5sum $API_DOCS_TEMPDIR/_api-docs/inspect-api/*  

  # if [ -d $API_DOCS_TEMPDIR ]; then
  #   rm -rf $API_DOCS_TEMPDIR
  # fi
else
  log info "${iyellow}$head${nc}${iyellow}GIT_REPO${$bwhite} is not defined so assume local running${nc}"
fi
popd

exit 0
