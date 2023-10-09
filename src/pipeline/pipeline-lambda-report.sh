#!/usr/bin/env bash

head="[users-pipeline-report]"

[ -z $PIPELINEDIR ] && export PIPELINEDIR=.pipeline

. $PIPELINEDIR/.colors
. $PIPELINEDIR/.pipeline_aliases

cdir=$(pwd)

log info "${iyellow}$head${nc} going to copy lambda test reports {nc}"

# copy reports to build output
[ ! -d $PIPELINEDIR/pipeline_reports/coverage/lambda ] && mkdir -p $PIPELINEDIR/pipeline_reports/coverage/lambda;
[ ! -d $PIPELINEDIR/pipeline_reports/junit/lambda ] && mkdir -p $PIPELINEDIR/pipeline_reports/junit/lambda;
[ ! -d $PIPELINEDIR/pipeline_reports/defaults/lambda ] && mkdir -p $PIPELINEDIR/pipeline_reports/defaults/lambda;

cp -r $PIPELINEDIR/lambda/coverage/* $PIPELINEDIR/pipeline_reports/coverage/lambda; 
cp -r $PIPELINEDIR/lambda/reports/report.xml $PIPELINEDIR/pipeline_reports/junit/lambda;
cp -r $PIPELINEDIR/lambda/reports/report.html $PIPELINEDIR/pipeline_reports/defaults/lambda

cd $cdir
exit 0

