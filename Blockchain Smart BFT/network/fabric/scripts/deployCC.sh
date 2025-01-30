#!/bin/bash

source scripts/utils.sh

CHANNEL_NAME=${1:-"mychannel"}
CC_NAME=${2}
CC_SRC_PATH=${3}
CC_SRC_LANGUAGE=${4}
CC_VERSION=${5:-"1.0"}
CC_SEQUENCE=${6:-"1"}
CC_INIT_FCN=${7:-"NA"}
CC_END_POLICY=${8:-"NA"}
CC_COLL_CONFIG=${9:-"NA"}
DELAY=${10:-"3"}
MAX_RETRY=${11:-"5"}
VERBOSE=${12:-"false"}

println "executing with the following"
println "- CHANNEL_NAME: ${C_GREEN}${CHANNEL_NAME}${C_RESET}"
println "- CC_NAME: ${C_GREEN}${CC_NAME}${C_RESET}"
println "- CC_SRC_PATH: ${C_GREEN}${CC_SRC_PATH}${C_RESET}"
println "- CC_SRC_LANGUAGE: ${C_GREEN}${CC_SRC_LANGUAGE}${C_RESET}"
println "- CC_VERSION: ${C_GREEN}${CC_VERSION}${C_RESET}"
println "- CC_SEQUENCE: ${C_GREEN}${CC_SEQUENCE}${C_RESET}"
println "- CC_END_POLICY: ${C_GREEN}${CC_END_POLICY}${C_RESET}"
println "- CC_COLL_CONFIG: ${C_GREEN}${CC_COLL_CONFIG}${C_RESET}"
println "- CC_INIT_FCN: ${C_GREEN}${CC_INIT_FCN}${C_RESET}"
println "- DELAY: ${C_GREEN}${DELAY}${C_RESET}"
println "- MAX_RETRY: ${C_GREEN}${MAX_RETRY}${C_RESET}"
println "- VERBOSE: ${C_GREEN}${VERBOSE}${C_RESET}"

INIT_REQUIRED="--init-required"
# check if the init fcn should be called
if [ "$CC_INIT_FCN" = "NA" ]; then
  INIT_REQUIRED=""
fi

if [ "$CC_END_POLICY" = "NA" ]; then
  CC_END_POLICY=""
else
  CC_END_POLICY="--signature-policy $CC_END_POLICY"
fi

if [ "$CC_COLL_CONFIG" = "NA" ]; then
  CC_COLL_CONFIG=""
else
  CC_COLL_CONFIG="--collections-config $CC_COLL_CONFIG"
fi

# import utils
. scripts/envVar.sh
. scripts/ccutils.sh

function checkPrereqs() {
  jq --version >/dev/null 2>&1

  if [[ $? -ne 0 ]]; then
    errorln "jq command not found..."
    errorln
    errorln "Follow the instructions in the Fabric docs to install the prereqs"
    errorln "https://hyperledger-fabric.readthedocs.io/en/latest/prereqs.html"
    exit 1
  fi
}

## package the chaincode
./scripts/packageCC.sh $CC_NAME $CC_SRC_PATH $CC_SRC_LANGUAGE $CC_VERSION

PACKAGE_ID=$(peer lifecycle chaincode calculatepackageid ${CC_NAME}.tar.gz)

if [ "$CHANNEL_NAME" = "chbft" ]; then
  ## Install chaincode on all peer
  infoln "Installing chaincode on peer0.orgA..."
  installChaincode peer0.orgA
  infoln "Install chaincode on peer0.orgB..."
  installChaincode peer0.orgB
  infoln "Install chaincode on peer0.orgC..."
  installChaincode peer0.orgC
  infoln "Installing chaincode on peer1.orgA..."
  installChaincode peer1.orgA
  infoln "Install chaincode on peer1.orgB..."
  installChaincode peer1.orgB
  infoln "Install chaincode on peer1.orgC..."
  installChaincode peer1.orgC

  resolveSequence

  ## query whether the chaincode is installed
  queryInstalled peer0.orgA
  queryInstalled peer0.orgB
  queryInstalled peer0.orgC
  queryInstalled peer1.orgA
  queryInstalled peer1.orgB
  queryInstalled peer1.orgC

  ## approve the definition for org orgA
  approveForMyOrg peer0.orgA
  ## check whether the chaincode definition is ready to be committed
  ## expect org orgA to have approved and org orgB and orgC not to
  checkCommitReadiness peer0.orgA "\"orgAMSP\": true" "\"orgBMSP\": false" "\"orgCMSP\": false"
  checkCommitReadiness peer0.orgB "\"orgAMSP\": true" "\"orgBMSP\": false" "\"orgCMSP\": false"
  checkCommitReadiness peer0.orgC "\"orgAMSP\": true" "\"orgBMSP\": false" "\"orgCMSP\": false"

  ## approve the definition for org orgA
  ##approveForMyOrg peer1.orgA
  ## check whether the chaincode definition is ready to be committed
  ## expect org orgA to have approved and org orgB and orgC not to
  ##checkCommitReadiness peer1.orgA "\"orgAMSP\": true" "\"orgBMSP\": false" "\"orgCMSP\": false"
  ##checkCommitReadiness peer1.orgB "\"orgAMSP\": true" "\"orgBMSP\": false" "\"orgCMSP\": false"
  ##checkCommitReadiness peer1.orgC "\"orgAMSP\": true" "\"orgBMSP\": false" "\"orgCMSP\": false"

  ## now approve also for org orgB
  approveForMyOrg peer0.orgB
  ## check whether the chaincode definition is ready to be committed
  ## expect 2 aprroved
  checkCommitReadiness peer0.orgA "\"orgAMSP\": true" "\"orgBMSP\": true" "\"orgCMSP\": false"
  checkCommitReadiness peer0.orgB "\"orgAMSP\": true" "\"orgBMSP\": true" "\"orgCMSP\": false"
  checkCommitReadiness peer0.orgC "\"orgAMSP\": true" "\"orgBMSP\": true" "\"orgCMSP\": false"

  ## now approve also for org orgB
  ##approveForMyOrg peer1.orgB
  ## check whether the chaincode definition is ready to be committed
  ## expect 2 aprroved
  ##checkCommitReadiness peer1.orgA "\"orgAMSP\": true" "\"orgBMSP\": true" "\"orgCMSP\": false"
  ##checkCommitReadiness peer1.orgB "\"orgAMSP\": true" "\"orgBMSP\": true" "\"orgCMSP\": false"
  ##checkCommitReadiness peer1.orgC "\"orgAMSP\": true" "\"orgBMSP\": true" "\"orgCMSP\": false"

  ## now approve also for org orgC
  approveForMyOrg peer0.orgC
  ## check whether the chaincode definition is ready to be committed
  ## expect all aprroved
  checkCommitReadiness peer0.orgA "\"orgAMSP\": true" "\"orgBMSP\": true" "\"orgCMSP\": true"
  checkCommitReadiness peer0.orgB "\"orgAMSP\": true" "\"orgBMSP\": true" "\"orgCMSP\": true"
  checkCommitReadiness peer0.orgC "\"orgAMSP\": true" "\"orgBMSP\": true" "\"orgCMSP\": true"

  ## now approve also for org orgC
  ##approveForMyOrg peer1.orgC
  ## check whether the chaincode definition is ready to be committed
  ## expect all aprroved
  ##checkCommitReadiness peer1.orgA "\"orgAMSP\": true" "\"orgBMSP\": true" "\"orgCMSP\": true"
  ##checkCommitReadiness peer1.orgB "\"orgAMSP\": true" "\"orgBMSP\": true" "\"orgCMSP\": true"
  ##checkCommitReadiness peer1.orgC "\"orgAMSP\": true" "\"orgBMSP\": true" "\"orgCMSP\": true"

  ## now that we know for sure all orgs have approved, commit the definition
  commitChaincodeDefinition peer0.orgA peer0.orgB peer0.orgC peer1.orgA peer1.orgB peer1.orgC

  ## query on all orgs to see that the definition committed successfully
  queryCommitted peer0.orgA
  queryCommitted peer0.orgB
  queryCommitted peer0.orgC
  queryCommitted peer1.orgA
  queryCommitted peer1.orgB
  queryCommitted peer1.orgC

  ## Invoke the chaincode - this does require that the chaincode have the 'initLedger'
  ## method defined
  if [ "$CC_INIT_FCN" = "NA" ]; then
    infoln "Chaincode initialization is not required"
  else
    chaincodeInvokeInit peer0.orgA peer0.orgB peer0.orgC peer1.orgA peer1.orgB peer1.orgC
  fi

  exit 0

else
  infoln "Nama Channel Chaincode Salah"

fi
