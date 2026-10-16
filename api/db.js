require('dotenv').config();
const mysql = require('mysql2/promise');

module.exports = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'Rv_Label',
  decimalNumbers: true, // DECIMAL vira number em vez de string
  // Banco hospedado (Aiven etc.) exige TLS: DB_SSL_CA = certificado CA em PEM (aceita \n escrito no lugar das quebras).
  ssl: process.env.DB_SSL_CA ? { ca: process.env.DB_SSL_CA.replace(/\\n/g, '\n') } : undefined,
});
