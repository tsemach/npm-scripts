#!/usr/bin/env bash

DIST=_dist

function usage() {
  echo ""
  echo "usage: npx publish <patch | minor | major> | <-a | --all> | <--types | -t>"  
  echo "  -a | --all: if -t | --types exist create types from all the package, otherwise if -t | --types exist create types just with src/types directory"
  echo "  -t | --types: create \$type@<package-name> for this package"
  echo ""
  echo "Examples"
  echo "  npx publish patch -a --types: publish while increament the patch by 1 and publish @types/<package-name>"
  echo "  npx publish patch -a -t: same as above"
  echo "  npx publish minor: publish just the package without @types<package-name> while increase the minor number"  
  echo ""
  echo "Environment Variables:"  
  echo "  NPM_PRIVATE_ARTIFACT - private artifact name to use in jforg"
  echo "  NPM_PUBLIC_ARTIFACT - publich artifact name to use in jforg"
  echo "  NPM_PRIVATE_REGISTRY  - an artifact to upload (publish) ims private packages"
  echo "  NPM_PUBLIC_REGISTRY   - an artifact to install publish packages from public registry"
  echo ""

  exit 1
}

function isCommit() {
  if [ -n "$(git status --porcelain -uno)" ]; then
    return 1
  else
    return 0
  fi
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

function createDist() {
  rm -rf $DIST
  mkdir $DIST

  cp -r dist/src/* $DIST  
  
  if [ ! -f .npmignore ]; then
    echo ""
    echo "ERROR: .npmignore must be exist in the project root direcotry"
    echo ""
    exit 1
  fi

  cp .npmignore $DIST
  packageDotJson=$(cat package.json)
  
  echo $packageDotJson "{\"main\": \"index.js\"}"  "{ \"files\": [ \"*\", \"package.json\" ] }" | jq -s add > $DIST/package.json  
}

if [ X$1 == Xhelp -o X$1 == X"--help" ]; then
  usage
fi

withBump=false
withTypes=false
withTypesAll=''

# isCommit
# if [ $? -ne 0 ]; then
#   echo ""
#   echo "  working directory is not clean, commit your code before publish"
#   echo ""

#   exit 1
# fi

while [ $# -gt 0 ]; do
  arg=$1; shift

  if [ $arg = "patch" -o $arg = "minor" -o $arg = "major" ]; then
    withBump=true
    bump=$arg
    continue
  fi

  if [ X$arg = X"-t" -o X$arg = X"--types" ]; then            
    withTypes=true
    continue
  fi

  if [ X$arg = X"-a" -o X$arg = X"--all" ]; then            
    withTypesAll=-a
    continue
  fi
  usage
done

if [ -f tsconfig.json ]; then
  npm run compile
fi

if [ X$withBump = X"true" ]; then
  echo "bumping with $bump"
  npm version $bump  
fi

createDist

if [ X$withTypes = X"true" ]; then
  name=$(jq -r '.name' package.json)
  echo "going to publish @types/${name}"
  npx types $withTypesAll
  ret=$?
fi

pushd $DIST > /dev/null
if [ X$withTypesAll = X"-a" ]; then
  find . -name "*.d.ts" -exec rm -f {} \;  
fi

_npmlogin private
echo "use $NPM_PRIVATE_REGISTRY to publish to .."
npm publish --access=public
ret=$?

popd > /dev/null

exit $ret
