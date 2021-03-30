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
  "tool"|"prod")
    echo -e "${COLOR}Running deployment for $1 environment\n========================================\n${SET}"
  ;;
  *)
    echo -e "${COLOR_RED}No environment defined!${SET}\nUse ./deploy.sh [tool | prod]" 
    exit
  ;;
esac

#############
# Variables #
#############

APP_NAME='grafana'
NAMESPACE='infra-monitoring'
VERSION='6.1.10'
HELM_REPO_URL='https://grafana.github.io/helm-charts'
HELM_REPO_NAME='grafana'
HELM_REPO_PATH='grafana/grafana'
VALUES_FILE='values-common.yaml'
EXTRA_FILE="extra-$1.yaml"

###########
# Scripts #
###########

echo -e "${COLOR}Adding ${APP_NAME} repository...${SET}"
helm repo add ${HELM_REPO_NAME} ${HELM_REPO_URL}
helm repo update

if [[ -d "custom/$1" ]]; then
    echo -e "${COLOR}Applying custom manifests...${SET}"
    kubectl apply --namespace ${NAMESPACE} -f custom/${1}/
fi

echo -e "${COLOR}Installing/Upgrading ${APP_NAME} chart...${SET}"
if [[ -s $EXTRA_FILE ]]; then
    VALUES_FILE="${VALUES_FILE},${EXTRA_FILE}"
fi

helm upgrade --install ${APP_NAME} ${HELM_REPO_PATH} -f ${VALUES_FILE} --namespace ${NAMESPACE} --version ${VERSION}