ORDERER_GENESIS_PROFILE=EtcdRaftOrdererGenesis # defined in configtx.yaml


genCrypto() {
  if [[ ! -d crypto-config ]]; then
      echo "Generating crypto materials"
      cryptogen generate --config=./crypto-config.yaml
  else 
    echo "Skipping crypto generation. crypto-config directory exists"
  fi
}

genChannelArtifacts() {
  CHANNEL_PROFILE=$1
  CHANNEL_ID=$2
  if [[ ! -d channel-artifacts ]]; then
    configtxgen -profile ${ORDERER_GENESIS_PROFILE} -channelID sys-channel -outputBlock ./channel-artifacts/genesis.block
    configtxgen -profile ${CHANNEL_PROFILE} -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_ID
    configtxgen -profile ${CHANNEL_PROFILE} -outputAnchorPeersUpdate ./channel-artifacts/org1-msp-anchors.tx -channelID $CHANNEL_ID -asOrg Org1MSP
    configtxgen -profile ${CHANNEL_PROFILE} -outputAnchorPeersUpdate ./channel-artifacts/org2-msp-anchors.tx -channelID $CHANNEL_ID -asOrg Org2MSP
    configtxgen -profile ${CHANNEL_PROFILE} -outputAnchorPeersUpdate ./channel-artifacts/org3-msp-anchors.tx -channelID $CHANNEL_ID -asOrg Org3MSP
  else 
    echo "Skipping channel artifacts generation. channel-artifacts directory exists"
  fi
}