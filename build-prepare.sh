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

    if [[ "$ACTION" == "incremental" || "$ACTION" == "full" ]] ; then
        getV8 $V8_REVISION
        getDependencies

        buildV8
        buildJS1
    else
        [[ -f src/libs/libv8.so ]] || [[ -f src/libs/libv8.dylib ]] || exitWithError "Cannot find libv8.[so|dylib] - in src/libs/ so cannot do a quick build!"
        [[ -f src/libs/libicui18n.so ]] || [[ -f src/libs/libicui18n.dylib ]] || exitWithError "Cannot find libicui18n.[so|dylib] - in src/libs/ so cannot do a quick build!"
        [[ -f src/libs/libjs1.so ]] || [[ -f src/libs/libjs1.dylib ]] || exitWithError "Cannot find libjs1.[so|dylib] - at src/libs/ so cannot do a quick build!"
    fi
fi
