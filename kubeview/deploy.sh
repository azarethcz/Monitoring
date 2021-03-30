#!/bin/bash
set -e

##########
# Colors #
##########
COLOR='\033[1;93m'
COLOR_WARNING='\033[0;33m'
COLOR_RED='\033[1;91m'
SET='\033[0m'

###############
# First check #
###############
case $1 in
  "tool"|"stage")
    echo -e "${COLOR}Running deployment for $1 environment\n========================================\n${SET}"
  ;;
  *)
    echo -e "${COLOR_RED}No environment defined!${SET}\nUse ./deploy.sh [tool | stage]" 
    exit
  ;;
esac

#############
# Variables #
#############

APP_NAME='kubeview'
NAMESPACE='infra-apps'
VALUES_FILE='values-common.yaml'
HELM_REPO_TREE='chart/kubeview-0.1.18.tgz'
EXTRA_FILE="extra-$1.yaml"

###########
# Scripts #
###########

if [[ -d "custom/$1" ]]; then
    echo -e "${COLOR}Applying custom manifests...${SET}"
    kubectl apply --namespace ${NAMESPACE} -f custom/${1}/
fi

echo -e "${COLOR}Installing/Upgrading ${APP_NAME} chart...${SET}"
if [[ -s $EXTRA_FILE ]]; then
    VALUES_FILE="${VALUES_FILE},${EXTRA_FILE}"
fi

helm upgrade --install ${APP_NAME} ${HELM_REPO_TREE} -f ${VALUES_FILE} --namespace ${NAMESPACE}