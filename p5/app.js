const express = require('express');
const bodyParser = require('body-parser');
const plaidRoutes = require('./routes/plaid');
const dbRoutes = require('./routes/db');
const userRoutes = require('./routes/users');
const budgetRoutes = require('./routes/budgets')

const app = express();
app.use(bodyParser.json());

app.use('/plaid', plaidRoutes);
app.use('/db', dbRoutes);
app.use('/users', userRoutes);
app.use('/budgets', budgetRoutes);

app.listen(3000, () => {
    console.log('Server running on http://localhost:3000/');
});
