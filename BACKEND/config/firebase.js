import admin from "firebase-admin";
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

let serviceAccount;

if (process.env.FIREBASE_CREDENTIALS) {
  serviceAccount = JSON.parse(process.env.FIREBASE_CREDENTIALS);
} else {
  // Si estamos en local, buscamos el archivo físico en la computadora
  const __filename = fileURLToPath(import.meta.url);
  const __dirname = path.dirname(__filename);
  const jsonPath = path.join(__dirname, '../serviceAccountKey.json');
  serviceAccount = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

export default admin;