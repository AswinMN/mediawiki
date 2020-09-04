#!/usr/bin/env bash

source tests/util/test-env.sh
source tests/util/test-functions.sh

PURGE_ARG=""
HELM_VERSION=$(helm version --client --short)
if [[ "${HELM_VERSION}" =~ ": " ]]; then
	HELM_VERSION="$(echo $HELM_VERSION | awk '{print $2}')"
fi

HELM_VERSION=$(echo $HELM_VERSION | sed 's/^v//')

if version_lte "${HELM_VERSION}" "2"; then
	PURGE_ARG="--purge"
fi

helm delete ${PURGE_ARG} "${DEPLOYMENT_NAME}-mysql"
helm delete ${PURGE_ARG} "${DEPLOYMENT_NAME}-memcached"

kubectl delete namespaces "${DEPLOYMENT_NAME}" || true
