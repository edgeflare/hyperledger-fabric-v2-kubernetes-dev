FROM node:12-alpine
WORKDIR /app
COPY src/* ./src/
COPY package.json .
RUN npm i
EXPOSE 8080
CMD ["npm", "run", "start"]