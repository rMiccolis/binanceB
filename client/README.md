# Client

**This is the frontend application which connects to the API server in this project.**
**Client application makes use of client authentication and cookies and lets user to play and stop a continuous process (via server API) that actively performs trading actions on a specified crypto pair (like $BTC / $USDT).**

## .env file variables example

The following is is the server ip address and port. For example if you create the infrustructure using the script at ./infrastructure/start.sh here will be automatically put http://server_ip/server/ according to the kubernetes server ingress resource.\
You can find an example at /client/client.env.example

## Info

This template should help get you started developing with Vue 3 in Vite.

## Recommended IDE Setup

[VSCode](https://code.visualstudio.com/) + [Volar](https://marketplace.visualstudio.com/items?itemName=johnsoncodehk.volar) (and disable Vetur) + [TypeScript Vue Plugin (Volar)](https://marketplace.visualstudio.com/items?itemName=johnsoncodehk.vscode-typescript-vue-plugin).

## Customize configuration

See [Vite Configuration Reference](https://vitejs.dev/config/).

## Project Setup

```sh
npm install
```

### Compile and Hot-Reload for Development

```sh
npm run dev
```

### Compile and Minify for Production

```sh
npm run build
```

### Crypto Icons Source:

```sh
https://github.com/mdfarhaan/cryptoflash-icons-api
```
