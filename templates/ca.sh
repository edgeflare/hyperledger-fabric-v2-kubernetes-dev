ORG=$1
cat <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: ca
  name: ca
  namespace: ${ORG}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ca
  strategy: {}
  template:
    metadata:
      labels:
        app: ca
    spec:
      containers:
      - image: hyperledger/fabric-ca
        name: fabric-ca
        resources: {}
        command:
        - "sh"
        - "-c"
        - |
          cp -r /etc/hyperledger/ca-key-cert /etc/hyperledger/fabric-ca
          fabric-ca-server start -d -b admin:adminpw --port 7054 --csr.cn "org1" --csr.hosts "localhost 0.0.0.0 127.0.0.1"
        envFrom:
        - configMapRef:
            name: ca
        volumeMounts:
        - name: ca-key-cert
          mountPath: "/etc/hyperledger/ca-key-cert"
      volumes:
      - name: ca-key-cert
        secret:
          secretName: ca
---
apiVersion: v1
kind: Service
metadata:
  name: ca
  namespace: ${ORG}
spec:
  selector:
    app: ca
  ports:
    - port: 7054
      targetPort: 7054
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: ca
  namespace: ${ORG}
data:
  FABRIC_CA_HOME: "/etc/hyperledger/fabric-ca"
  FABRIC_CA_CERT: "/etc/hyperledger/fabric-ca/ca-cert.pem"
  FABRIC_CA_KEY: "/etc/hyperledger/fabric-ca/ca-key.pem"
  FABRIC_CA_SERVER_PORT: "7054"
  FABRIC_CA_SERVER_CA_NAME: "ca-${ORG}"
  # TLS
  FABRIC_CA_SERVER_TLS_ENABLED: "true"
  FABRIC_CA_SERVER_TLS_CERTFILE: "/etc/hyperledger/fabric-ca/tls.crt"
  FABRIC_CA_SERVER_TLS_KEYFILE: "/etc/hyperledger/fabric-ca/tls.key"
EOF
