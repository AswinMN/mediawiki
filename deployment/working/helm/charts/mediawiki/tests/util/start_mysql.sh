#!/usr/bin/env bash

source tests/util/test-env.sh
source tests/util/test-functions.sh

helm repo add bitnami https://charts.bitnami.com/bitnami || true

OLD_TIMEOUT_VERSION="2.14"

# Get helm version
HELM_VERSION=$(helm version --client --short)

# Of course the helm version reporting itself differs between versions, making
# it work to even find out the version in the first place. If you needed any
# evidence of Microsoft's involvement in the helm project, this is it.
if [[ "${HELM_VERSION}" =~ ": " ]]; then
	HELM_VERSION="$(echo $HELM_VERSION | awk '{print $2}')"
fi

HELM_VERSION=$(echo $HELM_VERSION | sed 's/^v//')

TIMEOUT="5m0s"

# Current version is older than or equal to 2.14 which uses
# raw seconds as the timeout value
if version_lte "${HELM_VERSION}" "${OLD_TIMEOUT_VERSION}" ; then
	TIMEOUT=600
fi

CURENT_CONTEXT=$(kubectl config current-context)
kubectl create namespace "${DEPLOYMENT_NAME}" || true
kubectl config set-context --current=true --namespace="${DEPLOYMENT_NAME}"

# Install a MySQL database that we can use with our test deployments
helm upgrade --install --namespace="${DEPLOYMENT_NAME}" --wait \
	--timeout="${TIMEOUT}" \
	--set "db.name=${DATABASE_NAME}" \
	--set "root.password=${DATABASE_ROOT_PASSWORD}" \
	--set "image.tag=${MYSQL_IMAGE_TAG}" \
	--set "persistence.enabled=false" \
	--set "slave.replicas=0" \
	"${DEPLOYMENT_NAME}-mysql" bitnami/mysql
