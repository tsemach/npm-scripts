#!/usr/bin/env bash

DIST=_dist

function usage() {
  echo ""
  echo "usage: npx install -t | -p | --package <package-name | -h | --help"    
  echo "  -p | --package: the package name to install"  
  echo "  -t | --types: install types of the package"
  echo "  -D | --debug: install package in devDependencies (debug)"
  echo ""
  echo "Examples"
  echo "  npx uninstall -p @ims/iot-lib  - uninstall @ims/iot-lib and @types/ims__iot-lib"
  echo "  npx uninstall axios            - uninstall only axios with no types"
  echo ""
  echo "Environment Variables:"  
  echo "  NPM_PRIVATE_ARTIFACT - private artifact name to use in jforg"
  echo "  NPM_PUBLIC_ARTIFACT - publich artifact name to use in jforg"
  echo "  NPM_PRIVATE_REGISTRY  - an artifact to upload (publish) ims private packages, default is ims-cloud-npm-dev-local"
  echo "  NPM_PUBLIC_REGISTRY   - an artifact to install publish packages from public registry, default is ims-cloud-npm-virtual"
  echo ""

  exit 1
}

function _npmlogin() {
  local registry=$1

  if [[ "$registry" = "private" ]]; then    
		cp ~/.npmrc .		
    npm config set registry -L project $NPM_PRIVATE_REGISTRY
	 
    return
  fi  
	
  if [[ "$registry" = "public" ]]; then    
		cp ~/.npmrc .
    npm config set -L project registry $NPM_PUBLIC_REGISTRY
    
    return
  fi  
}

function setTypesName() {
  local name=$1; shift  
  local type_name="@types/$name"

  if [[ ${name:0:1} == "@" ]]
  then
    name="${name:1}"
    head=$(echo $name | awk -F/ '{print $1}')
    tail=$(echo $name | awk -F/ '{print $2}')
    type_name="@types/${head}__${tail}"
  fi    
  echo $type_name
}

withTypes=""
withUninstall=true
withDebug=""
package_name=""

while [ $# -gt 0 ]; do
  arg=$1; shift

  if [ $arg = "-h" -o $arg = "--help" ]; then
    usage
    
    exit 0
  fi 
  
  if [ $arg = "-t" -o $arg = "--types" ]; then  
    withTypes="-t"
    
    continue
  fi

  if [ $arg = "-D" -o $arg = "--debug" ]; then  
    withDebug="-D"
    
    continue
  fi

  package_name=$arg
done

if [ X$package_name = X ]; then
  usage
 
  exit 0
fi

npx uninstall -p $package_name
npx install $withDebug $withTypes -p $package_name
