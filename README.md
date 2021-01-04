# Hyperledger Fabric v2 with Raft on Kubernetes

### Prerequisites
- Kubernetes cluster with at least 4GB memory and 2 vCPUs (tested on IBM Cloud free tier IKS)
- kubectl available on path and configured to use a cluster
- Fabric binaries available on path



![hyperledger-fabric-network](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/blockchaind/pumls/master/blockchain/hlf-k8s.puml)


Launch network
```
./hlf.sh up
```

Have peers joined to channel

```
./hlf.sh joinChannel
```

Chaincode lifecycle
```
./hlf.sh ccInstallApprove
./hlf.sh ccCommit
./hlf.sh ccInvoke # Creates greeting="Hello, World!"
./hlf.sh ccQuery # Reads greeting value
./hlf.sh ccInvokeUpdate # Updates greeting="Hello, Blockchain!"
./hlf.sh ccQuery # Reads greeting value to check update succeeded
```
