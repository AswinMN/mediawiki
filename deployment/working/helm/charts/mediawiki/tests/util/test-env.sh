
export DEPLOYMENT_NAME=${DEPLOYMENT_NAME-mediawiki-test}
export DATABASE_NAME=${DATABASE_NAME-testdb}
export DATABASE_USER=${DATABASE_USER-dbtestuser}
export DATABASE_PASSWORD=${DATABASE_PASSWORD-dbtestpassword}
export DATABASE_ROOT_PASSWORD=${DATABASE_ROOT_PASSWORD-dbrootpassword}
export DATABASE_SERVERS=${DATABASE_SERVERS-mediawiki-test-mysql}
export REGISTRY_HOSTNAME=${REGISTRY_HOSTNAME-${CI_REGISTRY-registry.triumf.ca}}
export REGISTRY_USER=${REGISTRY_USER-gitlab-ci-token}
export REGISTRY_PASSWORD=${REGISTRY_PASSWORD-${CI_BUILD_TOKEN}}

export MYSQL_IMAGE_TAG="5.7"

if [ -z "${REGISTRY_USER}" ] || [ -z "${REGISTRY_PASSWORD}" ]; then
	echo "Don't forget you still need to export REGISTRY_USER and REGISTRY_PASSWORD"
fi
