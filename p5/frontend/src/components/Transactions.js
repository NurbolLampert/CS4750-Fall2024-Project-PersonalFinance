import React, { useState, useEffect } from 'react';
import axios from 'axios';

const Transactions = () => {
    const [transactions, setTransactions] = useState([]);
    const [plaidTransactions, setPlaidTransactions] = useState([]);
    const userId = localStorage.getItem('user_id');

    useEffect(() => {
        // Fetch database transactions
        axios.get(`/db/transactions/${userId}`)
            .then((response) => setTransactions(response.data))
            .catch((error) => console.error('Error fetching transactions:', error));
    }, [userId]);

    const createLinkToken = async () => {
        try {
            const response = await axios.post('/plaid/create-link-token', { user_id: userId });
            const { link_token } = response.data;

            const handler = window.Plaid.create({
                token: link_token,
                onSuccess: async (public_token) => {
                    await axios.post('/plaid/exchange-token', { public_token, user_id: userId });
                    fetchPlaidTransactions();
                },
            });

            handler.open();
        } catch (error) {
            console.error('Error creating Plaid Link token:', error);
        }
    };

const fetchPlaidTransactions = async (userId) => {
    try {
        const response = await axios.get(`/plaid/sandbox-transactions/${userId}`);
        console.log('Plaid Transactions:', response.data.transactions);
    } catch (error) {
        console.error('Error fetching Plaid transactions:', error);
    }
};


    return (
        <div style={{ padding: '20px' }}>
            <h2>Transactions</h2>
            <button
                onClick={createLinkToken}
                style={{
                    marginBottom: '20px',
                    padding: '10px 20px',
                    backgroundColor: '#007BFF',
                    color: 'white',
                    border: 'none',
                    borderRadius: '5px',
                    cursor: 'pointer',
                }}
            >
                Connect Bank Account
            </button>

            <h3>Database Transactions</h3>
            <table border="1" style={{ width: '100%', marginBottom: '20px' }}>
                <thead>
                    <tr>
                        <th>Transaction ID</th>
                        <th>Description</th>
                        <th>Amount</th>
                    </tr>
                </thead>
                <tbody>
                    {transactions.map((t) => (
                        <tr key={t.transaction_id}>
                            <td>{t.transaction_id}</td>
                            <td>{t.description}</td>
                            <td>${t.amount.toFixed(2)}</td>
                        </tr>
                    ))}
                </tbody>
            </table>

            {plaidTransactions.length > 0 && (
            <>
                <h3>Plaid Transactions</h3>
                <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: '20px' }}>
                    <thead>
                        <tr>
                            <th style={{ border: '1px solid #ddd', padding: '8px' }}>Date</th>
                            <th style={{ border: '1px solid #ddd', padding: '8px' }}>Name</th>
                            <th style={{ border: '1px solid #ddd', padding: '8px' }}>Category</th>
                            <th style={{ border: '1px solid #ddd', padding: '8px' }}>Amount</th>
                        </tr>
                    </thead>
                    <tbody>
                        {plaidTransactions.map((t) => (
                            <tr key={t.transaction_id}>
                                <td style={{ border: '1px solid #ddd', padding: '8px' }}>{t.date}</td>
                                <td style={{ border: '1px solid #ddd', padding: '8px' }}>{t.name}</td>
                                <td style={{ border: '1px solid #ddd', padding: '8px' }}>
                                    {t.category ? t.category.join(', ') : 'N/A'}
                                </td>
                                <td style={{ border: '1px solid #ddd', padding: '8px' }}>${t.amount.toFixed(2)}</td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </>
        )}
        </div>
    );
};

export default Transactions;
