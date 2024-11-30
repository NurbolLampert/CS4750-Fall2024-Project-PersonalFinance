const express = require('express');
const { Configuration, PlaidApi, PlaidEnvironments } = require('plaid');
const sql = require('mssql');
const router = express.Router();
const dbConfig = require('../dbConfig');
require('dotenv').config();

const configuration = new Configuration({
    basePath: PlaidEnvironments[process.env.PLAID_ENV],
    baseOptions: {
        headers: {
            'PLAID-CLIENT-ID': process.env.PLAID_CLIENT_ID,
            'PLAID-SECRET': process.env.PLAID_SECRET,
        },
    },
});
const client = new PlaidApi(configuration);

router.post('/create-link-token', async (req, res) => {
    const { user_id } = req.body; 
    try {
        const response = await client.linkTokenCreate({
            user: { client_user_id: user_id.toString() },
            client_name: 'My Financial App',
            products: ['transactions'],
            country_codes: ['US'],
            language: 'en',
        });
        res.json(response.data);
    } catch (error) {
        console.error('Error creating link token:', error.response?.data || error.message);
        res.status(500).json({ error: 'Failed to create link token' });
    }
});

router.post('/exchange-token', async (req, res) => {
    const { public_token, user_id } = req.body;
    try {
        const response = await client.itemPublicTokenExchange({ public_token });
        const access_token = response.data.access_token;
        const item_id = response.data.item_id;

        const pool = await sql.connect(dbConfig);
        await pool.request()
            .input('user_id', sql.Int, user_id)
            .input('access_token', sql.VarChar, access_token)
            .input('item_id', sql.VarChar, item_id)
            .query('INSERT INTO Plaid_Integration (user_id, access_token, item_id) VALUES (@user_id, @access_token, @item_id)');

        res.json({ message: 'Access token stored successfully' });
    } catch (error) {
        console.error('Error exchanging public token:', error.response?.data || error.message);
        res.status(500).json({ error: 'Failed to exchange token' });
    }
});

router.get('/sandbox-transactions/:user_id', async (req, res) => {
    const { user_id } = req.params;

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('user_id', sql.Int, user_id)
            .query('SELECT access_token FROM Plaid_Integration WHERE user_id = @user_id');

        if (result.recordset.length === 0) {
            return res.status(404).json({ error: 'No Plaid access token found for this user' });
        }

        const access_token = result.recordset[0].access_token;

        const response = await client.transactionsGet({
            access_token,
            start_date: '2024-01-01',
            end_date: '2024-12-31',
        });

        res.json({ transactions: response.data.transactions });
    } catch (error) {
        console.error('Error fetching Plaid transactions:', error.response?.data || error.message);
        res.status(500).json({ error: 'Failed to fetch transactions' });
    }
});


module.exports = router;
