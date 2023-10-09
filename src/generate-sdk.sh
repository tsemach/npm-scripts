#!/usr/bin/env bash

if [ $# -eq 0 ]; then
  echo "usage: `basename $0` docs/<openapi-yaml-file>"

  exit 1
fi

if [ ! -f $1 ]; then
  echo ""
  echo "ERROR: unable to find $1, abort"
  echo ""

  exit 1
fi

OPENAPI_DIRNAME=`dirname $1`
OPENAPI_FILENAME=`basename $1`

PACKAGE_NAME=`jq -r '.name' package.json`
OPENAPI_DIR=.openapi
SDK_DIR=${OPENAPI_DIR}/

[ ! -d $OPENAPI_DIR ] && mkdir $OPENAPI_DIR
[ -d ${OPENAPI_DIR}/$OPENAPI_FILENAME-sdk ] && rm -rf ${OPENAPI_DIR}/$OPENAPI_FILENAME-sdk

docker run \
  --user `id -u`:`id -g` \
  --rm \
  -v \
  `pwd`:/local \
  openapitools/openapi-generator-cli \
  generate \
  -i \
  /local/$OPENAPI_DIRNAME/$OPENAPI_FILENAME \
  -g \
  typescript-axios \
  --package-name \
  @gvdlsdks/$PACKAGE_NAME-sdk \
  -o \
  /local/${OPENAPI_DIR}/$OPENAPI_FILENAME-sdk \
  --additional-properties=npmName=@gvdlsdks/${PACKAGE_NAME}-sdk,supportsES6=true,withInterfaces=true,generateAliasAsModel=true \

pushd $OPENAPI_DIR/$OPENAPI_FILENAME-sdk

npm i
npm publish

if [ $? -ne 0 ]; then
  echo ""
  echo "ERROR: failed puslish $OPENAPI_DIR/$OPENAPI_FILENAME"
  echo ""
fi
popd 

exit 0