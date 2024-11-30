const express = require('express');
const sql = require('mssql');
const router = express.Router();
const dbConfig = require('../dbConfig');

router.post('/signup', async (req, res) => {
    const { username, password } = req.body;
    try {
        const pool = await sql.connect(dbConfig);
        await pool
            .request()
            .input('username', sql.VarChar, username)
            .input('password', sql.VarChar, password)
            .query('INSERT INTO Users (username, password_hash) VALUES (@username, @password)');
        res.json({ message: 'User registered successfully!' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.post('/login', async (req, res) => {
    const { username, password } = req.body;
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool
            .request()
            .input('username', sql.VarChar, username)
            .input('password', sql.VarChar, password)
            .query('SELECT * FROM Users WHERE username = @username AND password_hash = @password');

        if (result.recordset.length > 0) {
            const user = result.recordset[0];
            res.json({ message: 'Login successful', user_id: user.user_id, username: user.username });
        } else {
            res.status(401).json({ error: 'Invalid username or password' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
