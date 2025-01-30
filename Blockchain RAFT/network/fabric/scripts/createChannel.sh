#!/bin/bash

. scripts/envVar.sh

CHANNEL_NAME="$1"
DELAY="$2"
MAX_RETRY="$3"
VERBOSE="$4"
BFT="$5"

: ${CHANNEL_NAME:="chraft"}
: ${DELAY:="3"}
: ${MAX_RETRY:="5"}
: ${VERBOSE:="false"}
: ${BFT:=0}

createChannel() {
	local rc=1
	local COUNTER=1
	infoln "Adding orderers"
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
		sleep $DELAY
		set -x
		. scripts/orderer0-orgA.sh ${CHANNEL_NAME} >/dev/null 2>&1
		. scripts/orderer1-orgA.sh ${CHANNEL_NAME} >/dev/null 2>&1
		. scripts/orderer0-orgB.sh ${CHANNEL_NAME} >/dev/null 2>&1
		. scripts/orderer1-orgB.sh ${CHANNEL_NAME} >/dev/null 2>&1
		. scripts/orderer0-orgC.sh ${CHANNEL_NAME} >/dev/null 2>&1
		. scripts/orderer1-orgC.sh ${CHANNEL_NAME} >/dev/null 2>&1

		res=$?
		{ set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	verifyResult $res "Channel creation failed"
}

# joinChannel ORG
joinChannel() {
	ORG=$1
	setGlobals $ORG
	local rc=1
	local COUNTER=1
	## Sometimes Join takes time, hence retry
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
		sleep $DELAY
		set -x
		peer channel join -b $BLOCKFILE >&log.txt
		res=$?
		{ set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	verifyResult $res "After $MAX_RETRY attempts, ${ORG} has failed to join channel '$CHANNEL_NAME' "
}

setAnchorPeer() {
	ORG=$1
	. scripts/setAnchorPeer.sh $ORG $CHANNEL_NAME
}

BLOCKFILE="./channel-artifacts/${CHANNEL_NAME}.block"

## Create channel
infoln "Creating channel ${CHANNEL_NAME}"
createChannel
successln "Channel '$CHANNEL_NAME' created"

## Join all the peers to the channel
infoln "Joining peer0.orgA to the channel ${CHANNEL_NAME}"
joinChannel peer0.orgA
infoln "Joining peer0.orgB to the channel ${CHANNEL_NAME}"
joinChannel peer0.orgB
infoln "Joining peer0.orgC to the channel ${CHANNEL_NAME}"
joinChannel peer0.orgC
infoln "Joining peer1.orgA to the channel ${CHANNEL_NAME}"
joinChannel peer1.orgA
infoln "Joining peer1.orgB to the channel ${CHANNEL_NAME}"
joinChannel peer1.orgB
infoln "Joining peer1.orgC to the channel ${CHANNEL_NAME}"
joinChannel peer1.orgC

## Set the anchor peers for each org in the channel
infoln "Setting anchor peer for org orgA..."
setAnchorPeer peer0.orgA
infoln "Setting anchor peer for org orgB..."
setAnchorPeer peer0.orgB
infoln "Setting anchor peer for org orgC..."
setAnchorPeer peer0.orgC
infoln "Setting anchor peer for org orgA..."
setAnchorPeer peer1.orgA
infoln "Setting anchor peer for org orgB..."
setAnchorPeer peer1.orgB
infoln "Setting anchor peer for org orgC..."
setAnchorPeer peer1.orgC
	
successln "Channel '$CHANNEL_NAME' joined"
