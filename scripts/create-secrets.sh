creareOrdererSecret() {
    ORG=$1
    kubectl --namespace ${ORG} create secret generic orderer \
        --from-file=admincert.pem=crypto-config/ordererOrganizations/users/Admin\@/msp/admincerts/Admin\@-cert.pem \
        --from-file=cacert.pem=crypto-config/ordererOrganizations/ca/ca.-cert.pem \
        --from-file=key.pem=crypto-config/ordererOrganizations/orderers/orderer.${ORG}/msp/keystore/priv_sk \
        --from-file=cert.pem=crypto-config/ordererOrganizations/orderers/orderer.${ORG}/msp/signcerts/orderer.${ORG}-cert.pem \
        --from-file=tlsca-cert.pem=crypto-config/ordererOrganizations/tlsca/tlsca.-cert.pem \
        --from-file=tls.crt=crypto-config/ordererOrganizations/orderers/orderer.${ORG}/tls/server.crt \
        --from-file=tls.key=crypto-config/ordererOrganizations/orderers/orderer.${ORG}/tls/server.key \
        --from-file=genesis.block=channel-artifacts/genesis.block
}

createCASecrets() {
    ORG=$1
    kubectl --namespace ${ORG} create secret generic ca \
        --from-file=ca-cert.pem=crypto-config/peerOrganizations/${ORG}/ca/ca.${ORG}-cert.pem \
        --from-file=ca-key.pem=crypto-config/peerOrganizations/${ORG}/ca/priv_sk \
        --from-file=tls.crt=crypto-config/peerOrganizations/${ORG}/tlsca/tlsca.${ORG}-cert.pem \
        --from-file=tls.key=crypto-config/peerOrganizations/${ORG}/tlsca/priv_sk
}

createPeerSecret() {
    ORG=$1
    PEER=$2
    kubectl --namespace ${ORG} create secret generic ${PEER} \
        --from-file=key.pem=crypto-config/peerOrganizations/${ORG}/peers/${PEER}.${ORG}/msp/keystore/priv_sk \
        --from-file=cert.pem=crypto-config/peerOrganizations/${ORG}/peers/${PEER}.${ORG}/msp/signcerts/${PEER}.${ORG}-cert.pem \
        --from-file=tls.key=crypto-config/peerOrganizations/${ORG}/peers/${PEER}.${ORG}/tls/server.key \
        --from-file=tls.crt=crypto-config/peerOrganizations/${ORG}/peers/${PEER}.${ORG}/tls/server.crt \
        --from-file=tlsca-cert.pem=crypto-config/peerOrganizations/${ORG}/tlsca/tlsca.${ORG}-cert.pem \
        --from-file=ca-cert.pem=crypto-config/peerOrganizations/${ORG}/ca/ca.${ORG}-cert.pem \
        --from-file=config.yaml=nodeou.yaml \
        --from-file=orderer-tlsca-cert.pem=crypto-config/ordererOrganizations/orderers/orderer.${ORG}/msp/tlscacerts/tlsca.-cert.pem \
        --from-file=core.yaml
}

createOrgRootTLSCAsSecret() {
    ORG=$1
    kubectl --namespace ${ORG} create secret generic client-root-tlscas \
        --from-file=crypto-config/peerOrganizations/org1/tlsca/tlsca.org1-cert.pem \
        --from-file=crypto-config/peerOrganizations/org2/tlsca/tlsca.org2-cert.pem \
        --from-file=crypto-config/peerOrganizations/org3/tlsca/tlsca.org3-cert.pem
}

createAdminSecret() {
    ORG=$1
    kubectl --namespace ${ORG} create secret generic admin \
        --from-file=key.pem=crypto-config/peerOrganizations/${ORG}/users/Admin\@${ORG}/msp/keystore/priv_sk \
        --from-file=cert.pem=crypto-config/peerOrganizations/${ORG}/users/Admin\@${ORG}/msp/signcerts/Admin\@${ORG}-cert.pem \
        --from-file=tlsca-cert.pem=crypto-config/peerOrganizations/${ORG}/tlsca/tlsca.${ORG}-cert.pem \
        --from-file=ca-cert.pem=crypto-config/peerOrganizations/${ORG}/ca/ca.${ORG}-cert.pem \
        --from-file=tls.crt=crypto-config/peerOrganizations/${ORG}/users/Admin\@${ORG}/tls/client.crt \
        --from-file=tls.key=crypto-config/peerOrganizations/${ORG}/users/Admin\@${ORG}/tls/client.key \
        --from-file=orderer-tlsca-cert.pem=crypto-config/ordererOrganizations/orderers/orderer.${ORG}/msp/tlscacerts/tlsca.-cert.pem \
        --from-file=config.yaml=nodeou.yaml \
        --from-file=core.yaml
}

createChannelArtifactsSecrets() {
    ORG=$1
    kubectl --namespace ${ORG} create secret generic channel-artifacts \
        --from-file=channel.tx=channel-artifacts/channel.tx \
        --from-file=anchor-peer-update.tx=channel-artifacts/${ORG}-msp-anchors.tx
}
