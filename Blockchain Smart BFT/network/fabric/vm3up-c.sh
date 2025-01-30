#!/bin/bash
ROOTDIR=$(cd "$(dirname "$0")" && pwd)
export PATH=${ROOTDIR}/../bin:${PWD}/../bin:$PATH

# push to the required directory & set a trap to go back if needed
pushd ${ROOTDIR} >/dev/null
trap "popd > /dev/null" EXIT

. scripts/utils.sh

function networkUp() {
    if [ ! -d "organizations/peerOrganizations" ]; then
        fatalln "Make sure you have created crypto-material and copy to all vm!!"
    fi

    COMPOSE_FILES_COUCH="-c compose/compose-couch-vm3.yaml"

    docker stack deploy ${COMPOSE_FILES_COUCH} fabric-bft 2>&1

    if [ $? -ne 0 ]; then
        fatalln "Unable to up couchdb for vm3bft"
    fi

    successln "Successfully up couchdb for vm3bft"
}

infoln "Up couchdb for vm3"
networkUp
