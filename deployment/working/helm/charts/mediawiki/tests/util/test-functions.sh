#!/bin/bash

version_lte() {
	TEST_VERSION=$1
	BENCHMARK_VERSION=$2

	if [ -z "${TEST_VERSION}" ]; then
		echo "Invalid test version \`${TEST_VERSION}'" >&2
		exit 2
	fi
	if [ -z "${BENCHMARK_VERSION}" ]; then
		echo "Invalid benchmark version \`${BENCHMARK_VERSION}'" >&2
		exit 2
	fi

	if [ "${TEST_VERSION}" = "${BENCHMARK_VERSION}" ]; then
		return 1
	fi

	BENCHMARK_STR_LENGTH=$(($(echo $BENCHMARK_VERSION | wc -c)-1))
	TEST_VERSION_SUBSTR=$(echo $TEST_VERSION | cut -c-${BENCHMARK_STR_LENGTH})
	HIGHEST_VERSION=$(echo -e "${TEST_VERSION_SUBSTR}\n${BENCHMARK_VERSION}" | sort -V | head -1)

	if [ "${TEST_VERSION_SUBSTR}" = "${BENCHMARK_VERSION}" ]; then
		return 0
	fi

	if [ "${HIGHEST_VERSION}" != "${BENCHMARK_VERSION}" ]; then
		return 0
	fi

	return 1
}
