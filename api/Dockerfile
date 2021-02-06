FROM node:14
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build
ENV HLF_CCP_PATH=/var/hyperledger/connection.json HLF_MSPID=Org1MSP HLF_ORG_CA=ca.org1
CMD [ "npm", "run", "start:prod" ]
