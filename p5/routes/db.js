const express = require('express');
const sql = require('mssql');
const router = express.Router();
const dbConfig = require('../dbConfig');

router.get('/transactions/:user_id', async (req, res) => {
    const { user_id } = req.params;
    try {
        const pool = await sql.connect(dbConfig);

        const accounts = await pool.request()
            .input('user_id', sql.Int, user_id)
            .query('SELECT account_id FROM Account WHERE user_id = @user_id');

        if (accounts.recordset.length === 0) {
            return res.status(404).json({ error: 'No accounts found for this user' });
        }

        const accountIds = accounts.recordset.map(account => account.account_id);

        const transactions = await pool.request()
            .query(`SELECT * FROM Transactions WHERE account_id IN (${accountIds.join(',')})`);

        res.json(transactions.recordset);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.post('/transactions', async (req, res) => {
    const { account_id, amount, transaction_date, description } = req.body;

    try {
        const pool = await sql.connect(dbConfig);

        await pool.request()
            .input('account_id', sql.Int, account_id)
            .input('amount', sql.Decimal, amount)
            .input('transaction_date', sql.Date, transaction_date)
            .input('description', sql.VarChar, description)
            .query('INSERT INTO Transactions (account_id, amount, transaction_date, description) VALUES (@account_id, @amount, @transaction_date, @description)');

        await pool.request()
            .input('account_id', sql.Int, account_id)
            .input('amount', sql.Decimal, amount)
            .query('UPDATE Account SET balance = balance + @amount WHERE account_id = @account_id');

        res.json({ message: 'Transaction added and balance updated successfully!' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
});

router.delete('/transactions/:id', async (req, res) => {
    const { id } = req.params;

    try {
        const pool = await sql.connect(dbConfig);

        const transactionResult = await pool.request()
            .input('transaction_id', sql.Int, id)
            .query('SELECT account_id, amount FROM Transactions WHERE transaction_id = @transaction_id');

        if (transactionResult.recordset.length === 0) {
            return res.status(404).json({ message: 'Transaction not found' });
        }

        const { account_id, amount } = transactionResult.recordset[0];

        await pool.request()
            .input('transaction_id', sql.Int, id)
            .query('DELETE FROM Transactions WHERE transaction_id = @transaction_id');

        await pool.request()
            .input('account_id', sql.Int, account_id)
            .input('amount', sql.Decimal, amount)
            .query('UPDATE Account SET balance = balance - @amount WHERE account_id = @account_id');

        res.json({ message: 'Transaction deleted and balance updated successfully!' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
});





// Fetch accounts for a user
router.get('/accounts/:user_id', async (req, res) => {
    const { user_id } = req.params;
    try {
        const pool = await sql.connect(dbConfig);

        // Fetch accounts for the logged-in user
        const result = await pool.request()
            .input('user_id', sql.Int, user_id)
            .query('SELECT account_id, account_type, balance FROM Account WHERE user_id = @user_id');

        res.json(result.recordset);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
});

// routes/db.js
router.get('/budgets/accounts/:user_id', async (req, res) => {
    const { user_id } = req.params;
    try {
        const pool = await sql.connect(dbConfig);

        // Fetch all accounts for the user
        const accounts = await pool.request()
            .input('user_id', sql.Int, user_id)
            .query('SELECT account_id, account_type, balance FROM Account WHERE user_id = @user_id');

        if (accounts.recordset.length === 0) {
            return res.status(404).json({ error: 'No accounts found for this user' });
        }

        res.json(accounts.recordset); // Return all accounts for this user
    } catch (error) {
        console.error('Error fetching accounts:', error);
        res.status(500).json({ error: error.message });
    }
});



module.exports = router;
