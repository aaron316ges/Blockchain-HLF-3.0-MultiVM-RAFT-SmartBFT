#!/bin/bash

ROOTPATH=${ROOTPATH:-${PWD}}
. ${ROOTPATH}/scripts/configUpdate.sh

# NOTE: This requires jq and configtxlator for execution.
createAnchorPeerUpdate() {
  infoln "Fetching channel config for channel $CHANNEL_NAME"
  fetchChannelConfig $ORG $CHANNEL_NAME ${ROOTPATH}/channel-artifacts/${CORE_PEER_LOCALMSPID}config.json

  infoln "Generating anchor peer update transaction for ${ORG} on channel $CHANNEL_NAME"

  if [ $ORG = "peer0.orgA" ]; then
    HOST="peer0.orgA.raft.com"
    PORT=7051
  elif [ $ORG = "peer0.orgB" ]; then
    HOST="peer0.orgB.raft.com"
    PORT=8051
  elif [ $ORG = "peer0.orgC" ]; then
    HOST="peer0.orgC.raft.com"
    PORT=9051
  elif [ $ORG = "peer1.orgA" ]; then
    HOST="peer1.orgA.raft.com"
    PORT=10051
  elif [ $ORG = "peer1.orgB" ]; then
    HOST="peer1.orgB.raft.com"
    PORT=11051
  elif [ $ORG = "peer1.orgC" ]; then
    HOST="peer1.orgC.raft.com"
    PORT=12051
  else
    errorln "${ORG} unknown"
  fi

  set -x
  # Modify the configuration to append the anchor peer
  jq '.channel_group.groups.Application.groups.'${CORE_PEER_LOCALMSPID}'.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "'$HOST'","port": '$PORT'}]},"version": "0"}}' ${ROOTPATH}/channel-artifacts/${CORE_PEER_LOCALMSPID}config.json >${ROOTPATH}/channel-artifacts/${CORE_PEER_LOCALMSPID}modified_config.json
  res=$?
  { set +x; } 2>/dev/null
  verifyResult $res "Channel configuration update for anchor peer failed, make sure you have jq installed"

  # Compute a config update, based on the differences between
  # {orgmsp}config.json and {orgmsp}modified_config.json, write
  # it as a transaction to {orgmsp}anchors.tx
  createConfigUpdate ${CHANNEL_NAME} ${ROOTPATH}/channel-artifacts/${CORE_PEER_LOCALMSPID}config.json ${ROOTPATH}/channel-artifacts/${CORE_PEER_LOCALMSPID}modified_config.json ${ROOTPATH}/channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx
}

updateAnchorPeer() {
  peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer0.orgA-orderer.raft.com -c $CHANNEL_NAME -f ${ROOTPATH}/channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls --cafile "$ORDERER_ORGA_CA" >&log.txt
  res=$?
  cat log.txt
  verifyResult $res "Anchor peer update failed"
  successln "Anchor peer set for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL_NAME'"
}

ORG=$1
CHANNEL_NAME=$2

setGlobals $ORG

createAnchorPeerUpdate

updateAnchorPeer
