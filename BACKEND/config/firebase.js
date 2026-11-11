import pkg from 'firebase-admin';
const { admin } = pkg;
import admin from 'firebase-admin';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

let serviceAccount;

if (process.env.FIREBASE_CREDENTIALS) {
  serviceAccount = JSON.parse(process.env.FIREBASE_CREDENTIALS);
} else {
  const __filename = fileURLToPath(import.meta.url);
  const __dirname = path.dirname(__filename);
  const jsonPath = path.join(__dirname, '../serviceAccountKey.json');
  serviceAccount = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));
}

// Validación de seguridad para asegurarnos de que admin está definido
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

export default admin;