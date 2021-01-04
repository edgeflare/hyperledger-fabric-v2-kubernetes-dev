ORG=$1
PEER=$2
cat <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: ${PEER}
  name: ${PEER}
  namespace: ${ORG}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${PEER}
  strategy: {}
  template:
    metadata:
      labels:
        app: ${PEER}
    spec:
      containers:
      - name: couchdb
        image: hyperledger/fabric-couchdb
        env:
        - name: COUCHDB_USER
          value: couchdb
        - name: COUCHDB_PASSWORD
          value: couchdb
        ports:
        - containerPort: 5984
      - name: fabric-peer
        image: hyperledger/fabric-peer:2.3
        resources: {}
        envFrom:
        - configMapRef:
            name: ${PEER}
        volumeMounts:
        - name: dockersocket 
          mountPath: "/host/var/run/docker.sock"
        - name: ${PEER}
          mountPath: "/etc/hyperledger/fabric-peer"
        - name: client-root-tlscas
          mountPath: "/etc/hyperledger/fabric-peer/client-root-tlscas"  
      volumes:
      - name: dockersocket
        hostPath:
          path: "/var/run/docker.sock"
      - name: ${PEER}
        secret:
          secretName: ${PEER}
          items:
          - key: key.pem
            path: msp/keystore/key.pem
          - key: cert.pem
            path: msp/signcerts/cert.pem
          - key: tlsca-cert.pem
            path: msp/tlsca/tlsca-cert.pem
          - key: ca-cert.pem
            path: msp/cacerts/ca-cert.pem
          - key: config.yaml
            path: msp/config.yaml
          - key: tls.crt
            path: tls/tls.crt
          - key: tls.key
            path: tls/tls.key
          - key: orderer-tlsca-cert.pem
            path: orderer-tlsca-cert.pem
          - key: core.yaml
            path: core.yaml
      - name: client-root-tlscas
        secret:
          secretName: client-root-tlscas
---
apiVersion: v1
kind: ConfigMap
metadata:
  creationTimestamp: null
  name: ${PEER}
  namespace: ${ORG}
data:
  CORE_PEER_ADDRESSAUTODETECT: "true"
  CORE_PEER_ID: ${PEER}
  CORE_PEER_LISTENADDRESS: 0.0.0.0:7051
  CORE_PEER_PROFILE_ENABLED: "true"
  CORE_PEER_LOCALMSPID: $(echo ${ORG}MSP | sed s/o/O/) 
  CORE_PEER_MSPCONFIGPATH: /etc/hyperledger/fabric-peer/msp

  # Gossip
  $(if [ "$PEER" = "peer0" ]; then
  echo "CORE_PEER_GOSSIP_BOOTSTRAP: peer1.${ORG}:7051"
  else
  echo "CORE_PEER_GOSSIP_BOOTSTRAP: peer0.${ORG}:7051"
  fi)
  CORE_PEER_GOSSIP_EXTERNALENDPOINT: "${PEER}.${ORG}:7051"
  CORE_PEER_GOSSIP_ORGLEADER: "false"
  CORE_PEER_GOSSIP_USELEADERELECTION: "true"
  # TLS
  CORE_PEER_TLS_ENABLED: "true"
  CORE_PEER_TLS_CERT_FILE: "/etc/hyperledger/fabric-peer/tls/tls.crt"
  CORE_PEER_TLS_KEY_FILE: "/etc/hyperledger/fabric-peer/tls/tls.key"
  CORE_PEER_TLS_ROOTCERT_FILE: "/etc/hyperledger/fabric-peer/msp/tlsca/tlsca-cert.pem"
  CORE_PEER_TLS_CLIENTAUTHREQUIRED: "false"
  ORDERER_TLS_ROOTCERT_FILE: "/etc/hyperledger/fabric-peer/orderer-tlsca-cert.pem"
  CORE_PEER_TLS_CLIENTROOTCAS_FILES: "/etc/hyperledger/fabric-peer/client-root-tlscas/tlsca.org1-cert.pem, /etc/hyperledger/fabric-peer/client-root-tlscas/tlsca.org2-cert.pem, /etc/hyperledger/fabric-peer/client-root-tlscas/tlsca.org3-cert.pem"
  CORE_PEER_TLS_CLIENTCERT_FILE: "/etc/hyperledger/fabric-peer/tls/tls.crt"
  CORE_PEER_TLS_CLIENTKEY_FILE: "/etc/hyperledger/fabric-peer/tls/tls.key"
  # Docker
  CORE_PEER_NETWORKID: ${ORG}-fabnet
  CORE_VM_ENDPOINT: unix:///host/var/run/docker.sock
  CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE: "bridge"
  # CouchDB
  CORE_LEDGER_STATE_STATEDATABASE: CouchDB
  CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS: 0.0.0.0:5984
  CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME: couchdb
  CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD: couchdb
  # Logging
  CORE_LOGGING_PEER: "info"
  CORE_LOGGING_CAUTHDSL: "info"
  CORE_LOGGING_GOSSIP: "info"
  CORE_LOGGING_LEDGER: "info"
  CORE_LOGGING_MSP: "info"
  CORE_LOGGING_POLICIES: "debug"
  CORE_LOGGING_GRPC: "info"
  FABRIC_LOGGING_SPEC: "info"
  GODEBUG: "netdns=go"
  # CORE_PEER_CHAINCODEADDRESS: 0.0.0.0:7052
  # CORE_PEER_CHAINCODELISTENADDRESS: 0.0.0.0:7052
  # CORE_PEER_GOSSIP_ENDPOINT: "0.0.0.0:7051"
---
apiVersion: v1
kind: Service
metadata:
  name: ${PEER}
  namespace: ${ORG}
spec:
  selector:
    app: ${PEER}
  ports:
    - name: request
      port: 7051
      targetPort: 7051
    - name: event
      port: 7053
      targetPort: 7053
EOF
