# How to build the android APK

Go to  Capacitor documentation for more info: [capacitorjs](https://capacitorjs.com/docs/config)

## Install Capacitor

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

## Change default application icons

To set the application icon: (on Android Studio):

1. Right click on res folder and select new > image asset
2. Load and config icon from ./client/resources/binanceB_android_icon.jpg