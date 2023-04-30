vai su capacitor https://capacitorjs.com/
segui le guide
importa la cartella 'android' su android studio e falla partire


npm install @capacitor/cli @capacitor/core

npx cap init

npm install @capacitor/android @capacitor/ios 

1. cancella se esiste la cartella android
2. modificare file capacitor.config.json: "webDir": "dist"
3. crea la build: npm run build
4. crea la cartella android da importare in android studio: npx cap add android
