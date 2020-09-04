#!/bin/bash

DESTDIR="logs"
NAMESPACE=${NAMESPACE-${DEPLOYMENT_NAME-'deployment'}}
SEARCH="app=mediawiki"

usage() {
        cat >&2 <<EOOPTS
$(basename $0) [OPTIONS] <destdir>

OPTIONS:
  -h:         Print this help message

  -n <N>:     Use namespace <N>
              Default: $NAMESPACE
  -s <S>:     Search for relevant pod(s) with the search term <S> (this will be
              passed to kubectl -l)
              Default: $SEARCH
EOOPTS
}

while getopts "hn:s:" opt; do
   case $opt in
   h)
       usage
       exit 0
       ;;
   n)
       NAMESPACE=$OPTARG
       ;;
   s)
       SEARCH=$OPTARG
       ;;
   *)
       echo "Invalid option: -$OPTARG" >&2
       exit 1
       ;;
    esac
done

shift "$((OPTIND - 1))"
DESTDIR=$1

mkdir -p "${DESTDIR}"
for p in $(kubectl --namespace=${NAMESPACE} get pods -l ${SEARCH} -o jsonpath='{.items[*].metadata.name}'); do
	kubectl --namespace=${NAMESPACE} logs ${p} --all-containers=true 2>&1 | tee "${DESTDIR}/${p}"
done

# vim: ts=4 sw=4 expandtab
