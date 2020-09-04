#!/usr/bin/env bash

source tests/util/test-env.sh

helm upgrade --install "${DEPLOYMENT_NAME}-memcached" \
	--namespace="${DEPLOYMENT_NAME}" \
	--set "replicaCount=1" \
	stable/memcached
