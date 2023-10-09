#!/bin/bash

function npmlogin() {
  local opts=()
  if [[ "$1" == "private" ]]; then
    opts+=(
      --region us-west-2
      --repository geospatial-private-npm
      )
  else # "$1" == "cache"
    opts+=(
      --region us-west-2
      --repository geospatial-npm-cache
      )
  fi
  echo aws codeartifact login $CICDGIT_PROFILE --tool npm "${opts[@]}" --domain intel-geospatial --domain-owner 908240026853  

  aws codeartifact login $CICDGIT_PROFILE \
    --tool npm "${opts[@]}" \
    --domain intel-geospatial \
    --domain-owner 908240026853
}

if [ X$AWS_PROFILE != X ]; then
  export CICDGIT_PROFILE="--profile cicdgit"
fi

npmlogin cache