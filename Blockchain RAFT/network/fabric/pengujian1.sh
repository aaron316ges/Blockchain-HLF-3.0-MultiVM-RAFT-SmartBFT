#!/bin/bash


    ID_ASSET="7890"
    START_TIME=$(date +%s%3N)

    echo "Menjalankan transaksi dengan ID: $ID_ASSET"

    peer chaincode invoke -o localhost:7055 --ordererTLSHostnameOverride orderer1.orgA-orderer.raft.com --tls --cafile "${PWD}/organizations/ordererOrganizations/orgA-orderer.raft.com/orderers/orderer1.orgA-orderer.raft.com/msp/tlscacerts/tlsca.orgA-orderer.raft.com-cert.pem" -C chraft -n raftcc --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/orgA.raft.com/peers/peer0.orgA.raft.com/tls/ca.crt" --peerAddresses localhost:10051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/orgA.raft.com/peers/peer1.orgA.raft.com/tls/ca.crt" --peerAddresses localhost:8051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/orgB.raft.com/peers/peer0.orgB.raft.com/tls/ca.crt" --peerAddresses localhost:11051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/orgB.raft.com/peers/peer1.orgB.raft.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/orgC.raft.com/peers/peer0.orgC.raft.com/tls/ca.crt" --peerAddresses localhost:12051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/orgC.raft.com/peers/peer1.orgC.raft.com/tls/ca.crt" -c '{"function":"CreateAsset","Args":["'"$ID_ASSET"'","Michael Jackson Biography","Walter White","4-November-2024", "'"$START_TIME"'"]}'

