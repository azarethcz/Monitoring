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

APP_NAME='sentry'
NAMESPACE='infra-sentry'
VERSION='7.1.0'
HELM_REPO_URL='https://sentry-kubernetes.github.io/charts'
HELM_REPO_NAME='sentry'
HELM_REPO_PATH='sentry/sentry'
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
# Get system secret key decoded from the cluster
SENTRY_SYSTEM_SECRET_KEY=`kubectl get secrets system-secret-key --template={{.data."secretkey"}} | base64 --decode`

echo -e "${COLOR}Installing/Upgrading ${APP_NAME} chart...${SET}"
if [[ -s $EXTRA_FILE ]]; then
    VALUES_FILE="${VALUES_FILE},${EXTRA_FILE}"
fi

helm upgrade --install ${APP_NAME} ${HELM_REPO_PATH} -f ${VALUES_FILE} --namespace ${NAMESPACE} --version ${VERSION} --set system.secretKey=$SENTRY_SYSTEM_SECRET_KEY --timeout 20m --wait

echo -e "${COLOR}Patching deployment...${SET}"
kubectl patch deployment sentry-web --patch "$(cat custom/post-deploy/sentry-web-patch.yaml)"
