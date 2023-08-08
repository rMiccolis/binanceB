# Server

**This is the API server which let client application to login and query for user account information as well as wallet status (owned or staked crypto) on the Binance exchange.**
**This is the core application that connects to kubernetes cluster API and is able to launch a JOB (a continuous process that can be stopped by user) responsible for trading on a crypto pair (EX: $BTC / $USDT) to gain profits.**

## .env file variables example

Find an example of .env variables at /server/server.env.example

## Project Setup

```sh
npm install
```

### Run server for Development

```sh
nodemon server.js
```