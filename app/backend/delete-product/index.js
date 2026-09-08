const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const app = express();
app.use(cors());
app.use(express.json());
const PORT = process.env.PORT || 3004;
const dbConfig = { host: process.env.DB_HOST || 'localhost', user: process.env.DB_USER || 'alumno', password: process.env.DB_PASS || 'alumno123', database: process.env.DB_NAME || 'freshbox', port: process.env.DB_PORT || 3306 };

app.delete('/api/products/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const conn = await mysql.createConnection(dbConfig);
    const [existing] = await conn.execute('SELECT * FROM productos WHERE id = ?', [id]);
    if (existing.length === 0) { await conn.end(); return res.status(404).json({ error: 'Producto no encontrado' }); }
    await conn.execute('DELETE FROM productos WHERE id = ?', [id]);
    await conn.end();
    res.json({ message: 'Producto eliminado correctamente', id: parseInt(id) });
  } catch (error) { res.status(500).json({ error: 'Error al eliminar producto', detalle: error.message }); }
});

app.get('/health', (req, res) => res.json({ status: 'OK', service: 'delete-product', port: PORT }));
app.listen(PORT, () => console.log(`[delete-product] Puerto ${PORT}`));

// 2026 - Disenador asignatura: Ignacio A. Pastenet M.
