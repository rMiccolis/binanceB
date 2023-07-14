vai su capacitor https://capacitorjs.com/
segui le guide
importa la cartella 'android' su android studio e falla partire

```bash
npm install @capacitor/cli @capacitor/core

npx cap init

npm install @capacitor/android @capacitor/ios 
```

1. Cancella se esiste la cartella android
2. Modificare file capacitor.config.json: "webDir": "dist"
3. Modificare file capacitor.config.json: in "server.url" inserire l'ip del server in questo modo: "http://2.44.128.35" (se usi https modifica http con https)
4. Crea la build: ```npm run build```
5. Crea la cartella android da importare in android studio => ```npx cap add android```

To set the application icon: (on android studio)
1. Right click on res folder and select new > image asset
2. Load and config icon from ./client/resources/binanceB_android_icon.jpg