#!/usr/bin/env bash

source tests/util/test-env.sh
source tests/util/test-functions.sh

TIMEOUT="5m0s"
PURGE_ARG=""

HELM_VERSION="$(helm version --client --short)"
if [[ "${HELM_VERSION}" =~ ^Client ]]; then
	PURGE_ARG="--purge"
	TIMEOUT="600"
fi

echo -e "mediawiki:\n  wgMainCacheType: CACHE_MEMCACHED\n  wgMemCachedServers:\n  - hostname: ${DEPLOYMENT_NAME}-memcached:11211\n  weight: 1\n" > tests/memcached-values.yaml

OLD_TIMEOUT_VERSION="2.15"
PURGE_ARG=""
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
	PURGE_ARG="--purge"
	TIMEOUT=600
fi

set -e

#for i in tests/extensions/*.yaml; do
# approvedrevs.yaml
# categorytree.yaml
# confirm-account.yam
# math-daq.yaml
# nativesvghandler.yaml
# semanticmediawiki.yaml
# usermerge-daq.yaml
# wikieditor-daq.yaml
# breadcrumbs2.yaml
# confirm-account-daq.yaml
# ldap.yaml
# math.yaml
# replacetext.yaml
# svgedit.yaml
# usermerge.yaml
# wikieditor.yaml

for i in tests/extensions/*.yaml; do
	echo "Installing test config $i"
	helm upgrade --install --namespace=$DEPLOYMENT_NAME "${DEPLOYMENT_NAME}-wiki" --wait --timeout=${TIMEOUT} \
		--values tests/values-minimal.yaml --values tests/memcached-values.yaml --values $i \
	--set "mediawiki.wgDBName=${DATABASE_NAME}" \
	--set "mediawiki.wgDBUser=${DATABASE_USER}" \
	--set "mediawiki.wgDBPassword=${DATABASE_PASSWORD}" \
	--set "mediawiki.wgDBAdminPassword=${DATABASE_ROOT_PASSWORD}" \
	--set "mediawiki.wgDBServers={${DATABASE_SERVERS}}" \
	--set "registry.name=${REGISTRY_HOSTNAME}" \
	--set "registry.user=${REGISTRY_USER}" \
	--set "registry.password=${REGISTRY_PASSWORD}" \
	--set "rbac.enabled=yes" \
	--set "rbac.serviceAccountName=${DEPLOYMENT_NAME}-wiki-sa" \
	--set "imagePullPolicy=Always" .
	helm delete ${PURGE_ARG} "${DEPLOYMENT_NAME}-wiki"
done
