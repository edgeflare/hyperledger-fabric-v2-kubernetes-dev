ORG=$1
PEER=$2
CHANNEL_ID=$3
cat <<EOF
# k8s secret volume mounts are read-only
cp -r /var/hyperledger/channel-artifacts /var/hyperledger/channel-artifacts-rw
cd /var/hyperledger/channel-artifacts-rw

if [ "$PEER" = "peer0" ] && [ "$ORG" = "org1" ]; then
    peer channel create -c ${CHANNEL_ID} -f channel.tx \
      -o orderer.${ORG}:7050 --tls --cafile \$ORDERER_TLS_ROOTCERT_FILE
fi

peer channel fetch 0 -c ${CHANNEL_ID} -o orderer.${ORG}:7050 \
  --tls --cafile \$ORDERER_TLS_ROOTCERT_FILE channel.block
peer channel join -b channel.block -o orderer:${ORG}:7050 --tls \
  --cafile \$ORDERER_TLS_ROOTCERT_FILE 

if [ "$PEER" = "peer0" ]; then
    peer channel update -c ${CHANNEL_ID} -f anchor-peer-update.tx \
      -o orderer.${ORG}:7050 --tls  --cafile \$ORDERER_TLS_ROOTCERT_FILE
fi
EOF
