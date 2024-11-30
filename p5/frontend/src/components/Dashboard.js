import React, { useEffect, useState } from 'react';
import axios from 'axios';
import Budgets from './Budget';

const Dashboard = () => {
    const user_id = localStorage.getItem('user_id');
    const username = localStorage.getItem('username');
    const [transactions, setTransactions] = useState([]);
    const [accounts, setAccounts] = useState([]);
    const [plaidTransactions, setPlaidTransactions] = useState([]);

    useEffect(() => {
        axios.get(`/db/transactions/${user_id}`)
            .then(response => setTransactions(response.data))
            .catch(error => console.error(error));

        axios.get(`/db/accounts/${user_id}`)
            .then(response => setAccounts(response.data))
            .catch(error => console.error(error));
    }, [user_id]);

    const [newTransaction, setNewTransaction] = useState({ account_id: '', description: '', amount: '', transaction_date: '' });

    const handleAddTransaction = async (e) => {
        e.preventDefault();
        const userId = localStorage.getItem('user_id'); 
        try {
            await axios.post('/db/transactions', { ...newTransaction }); 
            const response = await axios.get(`/db/transactions/${userId}`); 
            setTransactions(response.data);
            const accountsResponse = await axios.get(`/db/accounts/${userId}`);
            setAccounts(accountsResponse.data);
            setNewTransaction({ account_id: '', description: '', amount: '', transaction_date: '' });
        } catch (error) {
            console.error(error);
        }
    };

    const handleDeleteTransaction = async (transactionId) => {
        const userId = localStorage.getItem('user_id');
        try {
            await axios.delete(`/db/transactions/${transactionId}`);
    
            const transactionsResponse = await axios.get(`/db/transactions/${userId}`);
            setTransactions(transactionsResponse.data);
    
            const accountsResponse = await axios.get(`/db/accounts/${userId}`);
            setAccounts(accountsResponse.data);
        } catch (error) {
            console.error(error);
        }
    };
    
    

    const createLinkToken = async () => {
        try {
            const response = await axios.post('/plaid/create-link-token', { user_id });
            const { link_token } = response.data;

            const handler = window.Plaid.create({
                token: link_token,
                onSuccess: async (public_token) => {
                    await axios.post('/plaid/exchange-token', { public_token, user_id });
                    fetchPlaidTransactions();
                },
            });

            handler.open();
        } catch (error) {
            console.error('Error creating Plaid Link token:', error);
        }
    };

    const fetchPlaidTransactions = async () => {
        try {
            const response = await axios.get(`/plaid/sandbox-transactions/${user_id}`);
            setPlaidTransactions(response.data.transactions);
        } catch (error) {
            console.error('Error fetching Plaid transactions:', error);
        }
    };

    return (
        <div style={{ margin: '20px' }}>
            <h2>Hello, {username}!</h2>

            <h3>Add Transaction</h3>
            <form onSubmit={(e) => handleAddTransaction(e)}>
    <label>
        Select Account:
        <select
            value={newTransaction.account_id}
            onChange={(e) => setNewTransaction({ ...newTransaction, account_id: e.target.value })}
            required
        >
            <option value="">-- Select Account --</option>
            {accounts.map((account) => (
                <option key={account.account_id} value={account.account_id}>
                    {account.account_type} (Balance: ${account.balance.toFixed(2)})
                </option>
            ))}
        </select>
    </label>
    <input
        type="text"
        placeholder="Description"
        value={newTransaction.description}
        onChange={(e) => setNewTransaction({ ...newTransaction, description: e.target.value })}
        required
    />
    <input
        type="number"
        placeholder="Amount"
        value={newTransaction.amount}
        onChange={(e) => setNewTransaction({ ...newTransaction, amount: e.target.value })}
        required
    />
    <input
        type="date"
        placeholder="Transaction Date"
        value={newTransaction.transaction_date}
        onChange={(e) => setNewTransaction({ ...newTransaction, transaction_date: e.target.value })}
        required
    />
    <button type="submit">Add Transaction</button>
</form>



            <h3>Your Transactions</h3>
            <table border="1" style={{ width: '100%', marginBottom: '20px' }}>
                <thead>
                    <tr>
                        <th>Transaction ID</th>
                        <th>Account ID</th>
                        <th>Description</th>
                        <th>Amount</th>
                        <th>Transaction Date</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    {transactions.map((t) => (
                        <tr key={t.transaction_id}>
                            <td>{t.transaction_id}</td>
                            <td>{t.account_id}</td>
                            <td>{t.description}</td>
                            <td>${t.amount.toFixed(2)}</td>
                            <td>{new Date(t.transaction_date).toLocaleDateString()}</td>
                            <td>
                                <button onClick={() => handleDeleteTransaction(t.transaction_id)}>
                                    Delete
                                </button>
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>

            <h3>Your Accounts</h3>
            <ul>
                {accounts.map(a => (
                    <li key={a.account_id}>Account ID: {a.account_id} - Type: {a.account_type} - Balance: ${a.balance}</li>
                ))}
            </ul>
            
            <Budgets userId={localStorage.getItem('user_id')} />

            <button
                onClick={createLinkToken}
                style={{
                    marginTop: '20px',
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

export default Dashboard;
