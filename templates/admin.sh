ORG=$1
PEER=$2
cat <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: admin
  name: admin
  namespace: ${ORG}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: admin
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: admin
    spec:
      containers:
      - image: hyperledger/fabric-tools:2.3
        name: fabric-tools
        command: ["sh", "-c", "while true; do echo $(date); sleep 3600; done"]
        envFrom:
        - configMapRef:
            name: admin
        volumeMounts:
        - name: dockersocket 
          mountPath: "/host/var/run/docker.sock"
        - name: admin
          mountPath: "/etc/hyperledger/adminmsp"
        - name: client-root-tlscas
          mountPath: "/etc/hyperledger/fabric-peer/client-root-tlscas"
        - name: channel-artifacts
          mountPath: "/var/hyperledger/channel-artifacts"
      volumes:
      - name: dockersocket
        hostPath:
          path: "/var/run/docker.sock"
      - name: client-root-tlscas
        secret:
          secretName: client-root-tlscas
      - name: admin
        secret:
          secretName: admin
          items:
          - key: key.pem
            path: keystore/key.pem
          - key: cert.pem
            path: signcerts/cert.pem
          - key: tlsca-cert.pem
            path: tlsca/tlsca-cert.pem
          - key: ca-cert.pem
            path: cacerts/ca-cert.pem
          - key: config.yaml
            path: config.yaml
          - key: tls.crt
            path: tls/tls.crt
          - key: tls.key
            path: tls/tls.key
          - key: orderer-tlsca-cert.pem
            path: orderer-tlsca-cert.pem
          - key: core.yaml
            path: core.yaml
      - name: channel-artifacts
        secret:
          secretName: channel-artifacts  

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: admin
  namespace: ${ORG}
data:
  CORE_VM_ENDPOINT: "unix:///host/var/run/docker.sock"
  CORE_PEER_NETWORKID: fabnet
  CORE_PEER_TLS_CLIENTAUTHREQUIRED: "false"
  FABRIC_LOGGING_SPEC: INFO
  CORE_PEER_ID: ${PEER}.${ORG}
  CORE_PEER_ADDRESS: ${PEER}.${ORG}:7051
  CORE_PEER_LOCALMSPID: $(echo ${ORG}MSP | sed s/o/O/)
  CORE_PEER_TLS_ENABLED: "true"
  CORE_PEER_TLS_CERT_FILE: "/etc/hyperledger/adminmsp/tls/tls.crt"
  CORE_PEER_TLS_KEY_FILE: "/etc/hyperledger/adminmsp/tls/tls.key"
  CORE_PEER_TLS_ROOTCERT_FILE: "/etc/hyperledger/adminmsp/tlsca/tlsca-cert.pem"
  CORE_PEER_MSPCONFIGPATH: "/etc/hyperledger/adminmsp"
  ORDERER_TLS_ROOTCERT_FILE: "/etc/hyperledger/adminmsp/orderer-tlsca-cert.pem"
  CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE: "bridge"
EOF
