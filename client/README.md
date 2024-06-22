# Client

**This is the frontend application which connects to the API server in this project.**
**Client application makes use of client authentication and cookies and lets user to play and stop a continuous process (via server API) that actively performs trading actions on a specified crypto pair (like $BTC / $USDT).**

## .env file variables example

VITE_SERVER_URI is the server ip address and port. For example if you create the infrustructure using the script at ./infrastructure/start.sh here will be automatically put http://$server_ip:$server_port/server/ according to the kubernetes server ingress resource. ($server_port needed if not the default port 80).\
**You can find an example at /client/client.env.example**

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

## How to build the android APK

Go to  Capacitor documentation for more info: [capacitorjs](https://capacitorjs.com/docs/config)

### Install Capacitor

```bash
npm install @capacitor/cli @capacitor/core

npx cap init

npm install @capacitor/android @capacitor/ios
```

1. Delete 'android' folder if already exists in the ./client/ dir
2. Edit capacitor.config.json: "webDir": "dist" (you have to specify the name of the build folder)
3. Edit capacitor.config.json: in "server.url" insert server ip with this format: "http://2.44.128.35" (if https used, replace http with https)
4. Create the project build: ```npm run build```
5. Create the android project folder (to be then imported on Android Studio) => ```npx cap add android```

6. To make cookies persist, insert the following function into the 'MainActivity.java' class and let Android Studio auto import the "CookieManager" class:

```java
@Override
    public void onPause() {
        super.onPause();

        CookieManager.getInstance().flush();
    }
```

7. Add this to you AndroidManifest.xml in the application element

```xml
<application
    android:usesCleartextTraffic="true"
```

### Change default application icons

To set the application icon: (on Android Studio):

1. Right click on res folder and select new > image asset
2. Load and config icon from ./client/resources/binanceB_android_icon.jpg
