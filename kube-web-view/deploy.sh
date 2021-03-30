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

APP_NAME='dashboard'
NAMESPACE='infra-apps'

###########
# Scripts #
###########

echo -e "${COLOR}Applying ${APP_NAME} manifests...${SET}"
kubectl apply --namespace ${NAMESPACE} -f deploy/

if [[ -d "custom/$1" ]]; then
    echo -e "${COLOR}Applying custom manifests...${SET}"
    kubectl apply --namespace ${NAMESPACE} -f custom/${1}/
fi