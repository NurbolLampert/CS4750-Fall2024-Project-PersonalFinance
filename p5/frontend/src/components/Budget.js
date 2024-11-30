import React, { useState, useEffect } from 'react';
import axios from 'axios';

const Budget = ({ userId }) => {
    const [budgets, setBudgets] = useState([]);
    const [accounts, setAccounts] = useState([]);
    const [newBudget, setNewBudget] = useState({
        account_id: '',
        category_id: '',
        amount: '',
        start_date: '',
        end_date: '',
    });

    const fetchBudgets = async () => {
        try {
            const response = await axios.get(`/budgets/${userId}`);
            setBudgets(response.data);
        } catch (error) {
            console.error('Error fetching budgets:', error);
        }
    };

    const fetchAccounts = async () => {
        try {
            const response = await axios.get(`/db/budgets/accounts/${userId}`);
            setAccounts(response.data);
        } catch (error) {
            console.error('Error fetching accounts:', error);
        }
    };

    const handleAddBudget = async (e) => {
        e.preventDefault();
        try {
            await axios.post('/budgets', { ...newBudget, user_id: userId });
            fetchBudgets(); 
            setNewBudget({ account_id: '', category_id: '', amount: '', start_date: '', end_date: '' }); 
        } catch (error) {
            console.error('Error adding budget:', error);
        }
    };

    const handleUpdateBudget = async (budgetId, updatedBudget) => {
        try {
            await axios.put(`/budgets/${budgetId}`, updatedBudget);
            fetchBudgets();
        } catch (error) {
            console.error('Error updating budget:', error);
        }
    };

    const handleDeleteBudget = async (budget_id) => {
        try {
            await axios.delete(`/budgets/${budget_id}`);
            fetchBudgets();
        } catch (error) {
            console.error('Error deleting budget:', error);
        }
    };

    useEffect(() => {
        fetchBudgets();
        fetchAccounts();
    }, []);

    return (
        <div>
            <h3>Your Budgets</h3>
            <ul>
                {budgets.map((budget) => (
                    <li key={budget.budget_id}>
                        {`Account: ${budget.account_id}, Category: ${budget.category_id}, Amount: $${budget.amount}`}
                        <button onClick={() => handleDeleteBudget(budget.budget_id)}>Delete</button>
                        <button
                            onClick={() =>
                                handleUpdateBudget(budget.budget_id, {
                                    amount: prompt('Enter new amount:', budget.amount),
                                    start_date: budget.start_date,
                                    end_date: budget.end_date,
                                })
                            }
                        >
                            Update
                        </button>
                    </li>
                ))}
            </ul>
            <h3>Add a Budget</h3>
            <form onSubmit={handleAddBudget}>
                <select
                    value={newBudget.account_id}
                    onChange={(e) => setNewBudget({ ...newBudget, account_id: e.target.value })}
                >
                    <option value="">Select Account</option>
                    {accounts.map((account) => (
                        <option key={account.account_id} value={account.account_id}>
                            {`${account.account_type} (Balance: $${account.balance})`}
                        </option>
                    ))}
                </select>
                <input
                    type="number"
                    placeholder="Category ID"
                    value={newBudget.category_id}
                    onChange={(e) => setNewBudget({ ...newBudget, category_id: e.target.value })}
                />
                <input
                    type="number"
                    placeholder="Amount"
                    value={newBudget.amount}
                    onChange={(e) => setNewBudget({ ...newBudget, amount: e.target.value })}
                />
                <input
                    type="date"
                    placeholder="Start Date"
                    value={newBudget.start_date}
                    onChange={(e) => setNewBudget({ ...newBudget, start_date: e.target.value })}
                />
                <input
                    type="date"
                    placeholder="End Date"
                    value={newBudget.end_date}
                    onChange={(e) => setNewBudget({ ...newBudget, end_date: e.target.value })}
                />
                <button type="submit">Add Budget</button>
            </form>
        </div>
    );
};

export default Budget;
