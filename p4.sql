-- p4


-- Part 1: Stored Procedures

-- Adds a new transaction record and assigns it to a specified category.
GO
CREATE PROCEDURE InsertTransaction
    @account_id INT,
    @category_id INT,
    @amount DECIMAL(15, 2),
    @transaction_date DATE,
    @description VARCHAR(255)
AS
BEGIN
    INSERT INTO Transactions (account_id, amount, transaction_date, description)
    VALUES (@account_id, @amount, @transaction_date, @description);

    INSERT INTO Transaction_Category (transaction_id, category_id)
    VALUES (SCOPE_IDENTITY(), @category_id);
END;
GO


-- Updates a financial goal's progress by adding a specified amount to the current progress.
CREATE PROCEDURE UpdateGoalProgress
    @goal_id INT,
    @amount DECIMAL(15, 2)
AS
BEGIN
    UPDATE Financial_Goal
    SET current_progress = current_progress + @amount
    WHERE goal_id = @goal_id;
END;
GO

-- Generates a summary of expenses for a specified user and month, compared to budgeted amounts.
CREATE PROCEDURE MonthlyBudgetSummary
    @user_id INT,
    @month INT,
    @year INT
AS
BEGIN
    SELECT b.category_id, c.category_name, SUM(e.amount) AS total_spent, b.amount AS budget
    FROM Budget b
    JOIN Expense e ON b.budget_id = e.budget_id
    JOIN Category c ON b.category_id = c.category_id
    WHERE b.user_id = @user_id AND MONTH(e.expense_date) = @month AND YEAR(e.expense_date) = @year
    GROUP BY b.category_id, c.category_name, b.amount;
END;
GO


-- Part 2: Functions

-- Calculates and returns the remaining budget for a specific budget ID.
GO
CREATE FUNCTION RemainingBudget(@budget_id INT)
RETURNS DECIMAL(15, 2)
AS
BEGIN
    DECLARE @remaining DECIMAL(15, 2);
    SET @remaining = (SELECT b.amount - COALESCE(SUM(e.amount), 0)
                      FROM Budget b
                      LEFT JOIN Expense e ON b.budget_id = e.budget_id
                      WHERE b.budget_id = @budget_id
                      GROUP BY b.amount);
    RETURN @remaining;
END;

GO

-- Returns the count of transactions associated with a specified category.
CREATE FUNCTION TransactionCountByCategory(@category_id INT)
RETURNS INT
AS
BEGIN
    RETURN (SELECT COUNT(*) FROM Transaction_Category WHERE category_id = @category_id);
END;
GO

-- Calculates and returns the completion percentage for a financial goal.
CREATE FUNCTION GoalProgress(@goal_id INT)
RETURNS DECIMAL(5, 2)
AS
BEGIN
    DECLARE @percentage DECIMAL(5, 2);
    SELECT @percentage = (current_progress * 100.0 / target_amount)
    FROM Financial_Goal
    WHERE goal_id = @goal_id;
    RETURN @percentage;
END;
GO


-- Part 3: Views

-- Displays account details along with the associated financial institution’s name.
GO
CREATE VIEW AccountSummary AS
SELECT a.account_id, a.account_type, a.balance, fi.institution_name
FROM Account a
JOIN Financial_Institution fi ON a.institution_id = fi.institution_id;
GO

-- Shows a detailed transaction history for each user, including category information.
CREATE VIEW UserTransactionHistory AS
SELECT u.username, t.transaction_id, t.amount, t.transaction_date, c.category_name
FROM Users u
JOIN Account a ON u.user_id = a.user_id
JOIN Transactions t ON a.account_id = t.account_id
JOIN Transaction_Category tc ON t.transaction_id = tc.transaction_id
JOIN Category c ON tc.category_id = c.category_id;
GO

-- Summarizes budget usage by showing total spent compared to the budgeted amount per category.
CREATE VIEW BudgetUsage AS
SELECT b.user_id, b.category_id, c.category_name, b.amount AS budget, SUM(e.amount) AS total_spent
FROM Budget b
JOIN Expense e ON b.budget_id = e.budget_id
JOIN Category c ON b.category_id = c.category_id
GROUP BY b.user_id, b.category_id, c.category_name, b.amount;
GO



-- Part 4: Trigger

-- Inserts a notification if a transaction causes the total spent to exceed the budget in a specific category.
CREATE TRIGGER BudgetExceedanceTrigger
ON Transactions
AFTER INSERT
AS
BEGIN
    DECLARE @user_id INT, @category_id INT, @budget_id INT, @total_spent DECIMAL(15, 2);

    -- Retrieve user and category ID
    SELECT @user_id = a.user_id, @category_id = tc.category_id
    FROM Inserted i
    JOIN Account a ON i.account_id = a.account_id
    JOIN Transaction_Category tc ON i.transaction_id = tc.transaction_id;

    -- Calculate total spent and budget ID with grouping
    SELECT @budget_id = b.budget_id, @total_spent = COALESCE(SUM(e.amount), 0)
    FROM Budget b
    LEFT JOIN Expense e ON b.budget_id = e.budget_id
    WHERE b.user_id = @user_id AND b.category_id = @category_id
    GROUP BY b.budget_id;

    -- Check if total spent exceeds budget and insert notification
    IF @total_spent > (SELECT amount FROM Budget WHERE budget_id = @budget_id)
    BEGIN
        INSERT INTO Notification (user_id, message, sent_date, type)
        VALUES (@user_id, 'Budget exceeded for ' + (SELECT category_name FROM Category WHERE category_id = @category_id), GETDATE(), 'Budget Alert');
    END;
END;
GO



-- Part 5: Column Encryption


-- Encrypts the password_hash column in the Users table to secure user passwords.
ALTER TABLE Users
ALTER COLUMN password_hash VARBINARY(512); -- Change data type for encryption

CREATE SYMMETRIC KEY UserPasswordKey
WITH ALGORITHM = AES_256
ENCRYPTION BY PASSWORD = 'strong_password';

-- Encrypt existing data
OPEN SYMMETRIC KEY UserPasswordKey
DECRYPTION BY PASSWORD = 'strong_password';

UPDATE Users
SET password_hash = EncryptByKey(Key_GUID('UserPasswordKey'), CAST(password_hash AS VARCHAR(255)));

CLOSE SYMMETRIC KEY UserPasswordKey;
GO


-- Part 6: Non-Clustered Indexes

-- Speeds up queries filtering or sorting by transaction_date in the Transactions table
CREATE NONCLUSTERED INDEX IX_TransactionDate ON Transactions(transaction_date);
GO
-- Optimizes lookups for goals related to a specific user in Financial_Goal
CREATE NONCLUSTERED INDEX IX_UserID_Goal ON Financial_Goal(user_id);
GO
-- Enhances performance of queries involving account balance filtering in Account
CREATE NONCLUSTERED INDEX IX_AccountBalance ON Account(balance);
GO