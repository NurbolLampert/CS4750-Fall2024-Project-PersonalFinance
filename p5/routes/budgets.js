const express = require('express');
const sql = require('mssql');
const router = express.Router();
const dbConfig = require('../dbConfig');

router.get('/:user_id', async (req, res) => {
    const { user_id } = req.params;
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('user_id', sql.Int, user_id)
            .query('SELECT * FROM Budget WHERE user_id = @user_id');
        res.json(result.recordset);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.post('/', async (req, res) => {
    const { user_id, account_id, category_id, amount, start_date, end_date } = req.body;
    try {
        const pool = await sql.connect(dbConfig);
        await pool.request()
            .input('user_id', sql.Int, user_id)
            .input('account_id', sql.Int, account_id)
            .input('category_id', sql.Int, category_id)
            .input('amount', sql.Decimal, amount)
            .input('start_date', sql.Date, start_date)
            .input('end_date', sql.Date, end_date)
            .query(
                `INSERT INTO Budget (user_id, account_id, category_id, amount, start_date, end_date)
                 VALUES (@user_id, @account_id, @category_id, @amount, @start_date, @end_date)`
            );
        res.json({ message: 'Budget added successfully!' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.put('/:budget_id', async (req, res) => {
    const { budget_id } = req.params;
    const { amount, start_date, end_date } = req.body;
    try {
        const pool = await sql.connect(dbConfig);
        await pool.request()
            .input('budget_id', sql.Int, budget_id)
            .input('amount', sql.Decimal, amount)
            .input('start_date', sql.Date, start_date)
            .input('end_date', sql.Date, end_date)
            .query(
                `UPDATE Budget 
                 SET amount = @amount, start_date = @start_date, end_date = @end_date 
                 WHERE budget_id = @budget_id`
            );
        res.json({ message: 'Budget updated successfully!' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.delete('/:budget_id', async (req, res) => {
    const { budget_id } = req.params;
    try {
        const pool = await sql.connect(dbConfig);
        await pool.request()
            .input('budget_id', sql.Int, budget_id)
            .query('DELETE FROM Budget WHERE budget_id = @budget_id');
        res.json({ message: 'Budget deleted successfully!' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
