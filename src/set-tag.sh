#!/bin/bash

. .colors
. .aliases

function checkEnv() {
  local env=$1: shift

  case $1 in
    dev) return 0 ;;   
    qa) return 0 ;;
    staging) return 0 ;;
    prod) return 0 ;;
  esac
  log info "${ired}usage: set-tag dev | qa | staging | prod ${nc}"

  exit 1  
}

function getPerviousEnv() {
  local env=$1: shift
  local prev=dev

  case $1 in
    dev) prev=dev 
    ;;   
    qa) prev=dev 
    ;;
    staging) prev=qa
    ;;
    prod) prev=staging
    ;;
    *)      
      log info "${ired}env should be one of dev | qa | staging | prod ${nc}"

      exit 1  
    ;;  
  esac
  echo $prev

  return 0
}

if [ $# -eq 0 ]; then
  log info "${ired}usage: set-tag <tag-name>${nc}"

  exit 1
fi

tagname=$1; shift
checkEnv $tagname

log info "${iyellow}working with ACCOUNT_ID=${iwhite}${ACCOUNT_ID}${iyellow}, REGION=${iwhite}${REGION}${nc}"
log info "${iyellow}tag name: ${iwhite}${tagname}${iyellow}${nc}"

curtime=$(date +"%Y/%m/%d:%H_%M_%S")
p="$(getPerviousEnv $tagname)"

prev_commit=$(git rev-list -1 "$(getPerviousEnv $tagname)" | cut -c1-8)
log info "${iyellow}prev_commit: ${iwhite}${prev_commit}${iyellow}${nc}"

latest_commit=$(git rev-parse HEAD | cut -c1-8)
git tag -d $tagname
git push origin :refs/tags/"$tagname"
msg="[$curtime] commit move $prev_commit=>$latest_commit"
git tag "$tagname" -m "$msg"
#git push origin "$tagname" --tags
git push origin "$tagname"
ret=$?

log info "${iyellow}set tag ${iwhite}${tagname}${iyellow} with tag message: ${iwhite}${msg}${nc}"

exit $ret
