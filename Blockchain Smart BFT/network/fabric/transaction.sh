#!/bin/bash

for i in {1..10}; do

    ID_ASSET="${i}"

    START_TIME=$(date +%s%3N)

    echo "Menjalankan transaksi $i dengan ID: $ID_ASSET"

    peer chaincode invoke -o localhost:7055 --ordererTLSHostnameOverride orderer1.orgA-orderer.bft.com --tls --cafile "${PWD}/organizations/ordererOrganizations/orgA-orderer.bft.com/orderers/orderer1.orgA-orderer.bft.com/msp/tlscacerts/tlsca.orgA-orderer.bft.com-cert.pem" -C chbft -n bftcc --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/orgA.bft.com/peers/peer0.orgA.bft.com/tls/ca.crt" --peerAddresses localhost:10051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/orgA.bft.com/peers/peer1.orgA.bft.com/tls/ca.crt" --peerAddresses localhost:8051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/orgB.bft.com/peers/peer0.orgB.bft.com/tls/ca.crt" --peerAddresses localhost:11051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/orgB.bft.com/peers/peer1.orgB.bft.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/orgC.bft.com/peers/peer0.orgC.bft.com/tls/ca.crt" --peerAddresses localhost:12051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/orgC.bft.com/peers/peer1.orgC.bft.com/tls/ca.crt" -c '{"function":"CreateAsset","Args":["'"$ID_ASSET"'","Michael Jackson Biography","Walter White","4-November-2024", "'"$START_TIME"'"]}'

    echo "--------------------------------------"

    sleep 1
done

echo "Semua transaksi telah disimpan"