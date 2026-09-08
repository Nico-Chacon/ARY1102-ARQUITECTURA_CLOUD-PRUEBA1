const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const app = express();
app.use(cors());
app.use(express.json());
const PORT = process.env.PORT || 3001;
const dbConfig = { host: process.env.DB_HOST || 'localhost', user: process.env.DB_USER || 'alumno', password: process.env.DB_PASS || 'alumno123', database: process.env.DB_NAME || 'freshbox', port: process.env.DB_PORT || 3306 };

app.get('/api/products', async (req, res) => {
  try {
    const conn = await mysql.createConnection(dbConfig);
    const [rows] = await conn.execute('SELECT * FROM productos ORDER BY id DESC');
    await conn.end();
    res.json(rows);
  } catch (error) { res.status(500).json({ error: 'Error al consultar productos', detalle: error.message }); }
});

app.get('/api/products/:id', async (req, res) => {
  try {
    const conn = await mysql.createConnection(dbConfig);
    const [rows] = await conn.execute('SELECT * FROM productos WHERE id = ?', [req.params.id]);
    await conn.end();
    if (rows.length === 0) return res.status(404).json({ error: 'Producto no encontrado' });
    res.json(rows[0]);
  } catch (error) { res.status(500).json({ error: 'Error', detalle: error.message }); }
});

app.get('/health', (req, res) => res.json({ status: 'OK', service: 'get-products', port: PORT }));
app.listen(PORT, () => console.log(`[get-products] Puerto ${PORT}`));

// 2026 - Disenador asignatura: Ignacio A. Pastenet M.
