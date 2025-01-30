#!/bin/bash

ROOTPATH=${ROOTPATH:-${PWD}}
. ${ROOTPATH}/scripts/utils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_ORGA_CA=${ROOTPATH}/organizations/ordererOrganizations/orgA-orderer.raft.com/tlsca/tlsca.orgA-orderer.raft.com-cert.pem
export ORDERER_ORGB_CA=${ROOTPATH}/organizations/ordererOrganizations/orgB-orderer.raft.com/tlsca/tlsca.orgB-orderer.raft.com-cert.pem
export ORDERER_ORGC_CA=${ROOTPATH}/organizations/ordererOrganizations/orgC-orderer.raft.com/tlsca/tlsca.orgC-orderer.raft.com-cert.pem
export PEER_ORGA_CA=${ROOTPATH}/organizations/peerOrganizations/orgA.raft.com/tlsca/tlsca.orgA.raft.com-cert.pem
export PEER_ORGB_CA=${ROOTPATH}/organizations/peerOrganizations/orgB.raft.com/tlsca/tlsca.orgB.raft.com-cert.pem
export PEER_ORGC_CA=${ROOTPATH}/organizations/peerOrganizations/orgC.raft.com/tlsca/tlsca.orgC.raft.com-cert.pem

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG = "peer0.orgA" ]; then
    export CORE_PEER_LOCALMSPID=orgAMSP
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER_ORGA_CA
    export CORE_PEER_MSPCONFIGPATH=${ROOTPATH}/organizations/peerOrganizations/orgA.raft.com/users/Admin@orgA.raft.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
  elif [ $USING_ORG = "peer0.orgB" ]; then
    export CORE_PEER_LOCALMSPID=orgBMSP
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER_ORGB_CA
    export CORE_PEER_MSPCONFIGPATH=${ROOTPATH}/organizations/peerOrganizations/orgB.raft.com/users/Admin@orgB.raft.com/msp
    export CORE_PEER_ADDRESS=localhost:8051
  elif [ $USING_ORG = "peer0.orgC" ]; then
    export CORE_PEER_LOCALMSPID=orgCMSP
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER_ORGC_CA
    export CORE_PEER_MSPCONFIGPATH=${ROOTPATH}/organizations/peerOrganizations/orgC.raft.com/users/Admin@orgC.raft.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
  elif [ $USING_ORG = "peer1.orgA" ]; then
    export CORE_PEER_LOCALMSPID=orgAMSP
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER_ORGA_CA
    export CORE_PEER_MSPCONFIGPATH=${ROOTPATH}/organizations/peerOrganizations/orgA.raft.com/users/Admin@orgA.raft.com/msp
    export CORE_PEER_ADDRESS=localhost:10051
  elif [ $USING_ORG = "peer1.orgB" ]; then
    export CORE_PEER_LOCALMSPID=orgBMSP
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER_ORGB_CA
    export CORE_PEER_MSPCONFIGPATH=${ROOTPATH}/organizations/peerOrganizations/orgB.raft.com/users/Admin@orgB.raft.com/msp
    export CORE_PEER_ADDRESS=localhost:11051
  elif [ $USING_ORG = "peer1.orgC" ]; then
    export CORE_PEER_LOCALMSPID=orgCMSP
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER_ORGC_CA
    export CORE_PEER_MSPCONFIGPATH=${ROOTPATH}/organizations/peerOrganizations/orgC.raft.com/users/Admin@orgC.raft.com/msp
    export CORE_PEER_ADDRESS=localhost:12051
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" = "true" ]; then
    env | grep CORE
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=()
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="$1"
    ## Set peer addresses
    if [ -z "$PEERS" ]; then
      PEERS="$PEER"
    else
      PEERS="$PEERS $PEER"
    fi
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" --peerAddresses $CORE_PEER_ADDRESS)
    ## Set path to TLS certificate
    CA=$CORE_PEER_TLS_ROOTCERT_FILE
    TLSINFO=(--tlsRootCertFiles "${CA}")
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" "${TLSINFO[@]}")
    # shift by one to get to the next organization
    shift
  done
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}
