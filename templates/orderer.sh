ORG=$1
cat <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: orderer
  name: orderer
  namespace: $ORG
spec:
  replicas: 1
  selector:
    matchLabels:
      app: orderer
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: orderer
    spec:
      containers:
      - image: hyperledger/fabric-orderer:2.3
        name: fabric-orderer
        envFrom:
        - configMapRef:
            name: orderer
        volumeMounts:
        - name: orderer
          mountPath: "/etc/hyperledger/fabric-orderer"   
      volumes:
      - name: orderer
        secret:
          secretName: orderer
          items:
          - key: admincert.pem
            path: msp/admincerts/admincert.pem
          - key: cacert.pem
            path: msp/cacerts/cacert.pem
          - key: key.pem
            path: msp/keystore/key.pem
          - key: cert.pem
            path: msp/signcerts/cert.pem
          - key: tlsca-cert.pem
            path: msp/tlscacerts/tlsca-cert.pem
          - key: tls.crt
            path: tls/tls.crt
          - key: tls.key
            path: tls/tls.key
          - key: genesis.block
            path: genesis.block
---
apiVersion: v1
kind: Service
metadata:
  name: orderer
  namespace: ${ORG}
spec:
  selector:
    app: orderer
  ports:
    - port: 7050
      targetPort: 7050
---
apiVersion: v1
kind: ConfigMap
metadata:
  creationTimestamp: null
  name: orderer
  namespace: $ORG
data:
  FABRIC_LOGGING_SPEC: INFO
  ORDERER_GENERAL_LISTENADDRESS: "0.0.0.0"
  ORDERER_GENERAL_GENESISMETHOD: file
  ORDERER_GENERAL_GENESISFILE: "/etc/hyperledger/fabric-orderer/genesis.block"
  ORDERER_GENERAL_LOCALMSPID: OrdererMSP
  ORDERER_GENERAL_LOCALMSPDIR: "/etc/hyperledger/fabric-orderer/msp"
  # TLS
  ORDERER_GENERAL_TLS_ENABLED: "true"
  ORDERER_GENERAL_TLS_PRIVATEKEY: "/etc/hyperledger/fabric-orderer/tls/tls.key"
  ORDERER_GENERAL_TLS_CERTIFICATE: "/etc/hyperledger/fabric-orderer/tls/tls.crt"
  ORDERER_GENERAL_TLS_ROOTCAS: "/etc/hyperledger/fabric-orderer/msp/tlscacerts/tlsca-cert.pem"
  ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY: "/etc/hyperledger/fabric-orderer/tls/tls.key"
  ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE: "/etc/hyperledger/fabric-orderer/tls/tls.crt"  
  ORDERER_GENERAL_CLUSTER_ROOTCAS: "/etc/hyperledger/fabric-orderer/msp/tlscacerts/tlsca-cert.pem"
EOF
