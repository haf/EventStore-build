#!/usr/bin/env bash
source build-complement.sh

checkParams $1 $2 $3 $4 $5

echo "Running from base directory: $BASE_DIR"

if [[ "$ACTION" == "full" ]] ; then
    cleanAll
fi

if [[ "$ACTION" == "js1" ]] ; then
    buildJS1
else
    buildEventStore
fi
