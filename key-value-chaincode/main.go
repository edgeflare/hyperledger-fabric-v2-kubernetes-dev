package main

import (
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

func main() {
	keyValueContract := new(KeyValueContract)

	cc, err := contractapi.NewChaincode(keyValueContract)

	if err != nil {
		panic(err.Error())
	}

	if err := cc.Start(); err != nil {
		panic(err.Error())
	}
}
