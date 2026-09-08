const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const app = express();
app.use(cors());
app.use(express.json());
const PORT = process.env.PORT || 3002;
const dbConfig = { host: process.env.DB_HOST || 'localhost', user: process.env.DB_USER || 'alumno', password: process.env.DB_PASS || 'alumno123', database: process.env.DB_NAME || 'freshbox', port: process.env.DB_PORT || 3306 };

app.post('/api/products', async (req, res) => {
  try {
    const { nombre, descripcion, precio, stock, categoria } = req.body;
    if (!nombre || !precio || stock === undefined) return res.status(400).json({ error: 'Campos obligatorios: nombre, precio, stock' });
    if (precio <= 0) return res.status(400).json({ error: 'El precio debe ser mayor a 0' });
    const conn = await mysql.createConnection(dbConfig);
    const [result] = await conn.execute('INSERT INTO productos (nombre, descripcion, precio, stock, categoria) VALUES (?, ?, ?, ?, ?)', [nombre, descripcion || null, precio, stock, categoria || null]);
    const [newProduct] = await conn.execute('SELECT * FROM productos WHERE id = ?', [result.insertId]);
    await conn.end();
    res.status(201).json(newProduct[0]);
  } catch (error) { res.status(500).json({ error: 'Error al crear producto', detalle: error.message }); }
});

app.get('/health', (req, res) => res.json({ status: 'OK', service: 'create-product', port: PORT }));
app.listen(PORT, () => console.log(`[create-product] Puerto ${PORT}`));

// 2026 - Disenador asignatura: Ignacio A. Pastenet M.
