CREATE DATABASE p3;

USE p3;

-- PART 1: CREATE TABLES

-- User Table (renamed to Users to avoid conflict with reserved keyword)
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME NOT NULL DEFAULT GETDATE()
);

-- Financial Institution Table
CREATE TABLE Financial_Institution (
    institution_id INT IDENTITY(1,1) PRIMARY KEY,
    institution_name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    contact_info VARCHAR(255)
);

-- Account Table
CREATE TABLE Account (
    account_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    institution_id INT NOT NULL,
    account_type VARCHAR(50) NOT NULL,
    balance DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (institution_id) REFERENCES Financial_Institution(institution_id)
);

-- Category Table
CREATE TABLE Category (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255)
);

-- Transaction Table (renamed to Transactions to avoid conflict with reserved keyword)
CREATE TABLE Transactions (
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    account_id INT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    transaction_date DATE NOT NULL,
    description VARCHAR(255),
    FOREIGN KEY (account_id) REFERENCES Account(account_id)
);

-- Transaction_Category Table (For Many-to-Many Relationship)
CREATE TABLE Transaction_Category (
    transaction_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (transaction_id, category_id),
    FOREIGN KEY (transaction_id) REFERENCES Transactions(transaction_id),
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

-- Budget Table
CREATE TABLE Budget (
    budget_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    account_id INT NOT NULL,
    category_id INT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (account_id) REFERENCES Account(account_id),
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

-- Expense Table
CREATE TABLE Expense (
    expense_id INT IDENTITY(1,1) PRIMARY KEY,
    budget_id INT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    expense_date DATE NOT NULL,
    description VARCHAR(255),
    FOREIGN KEY (budget_id) REFERENCES Budget(budget_id)
);

-- Financial Goal Table
CREATE TABLE Financial_Goal (
    goal_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    account_id INT NOT NULL,
    target_amount DECIMAL(15,2) NOT NULL,
    current_progress DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (account_id) REFERENCES Account(account_id)
);

-- Milestone Table
CREATE TABLE Milestone (
    milestone_id INT IDENTITY(1,1) PRIMARY KEY,
    goal_id INT NOT NULL,
    milestone_amount DECIMAL(15,2) NOT NULL,
    reached_date DATE,
    FOREIGN KEY (goal_id) REFERENCES Financial_Goal(goal_id)
);

-- Notification Table
CREATE TABLE Notification (
    notification_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    message VARCHAR(255) NOT NULL,
    sent_date DATETIME NOT NULL DEFAULT GETDATE(),
    type VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Plaid Integration Table
CREATE TABLE Plaid_Integration (
    plaid_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    institution_id INT NOT NULL,
    access_token VARCHAR(255) NOT NULL,
    item_id VARCHAR(255) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (institution_id) REFERENCES Financial_Institution(institution_id)
);

-- User Authentication Table
CREATE TABLE User_Authentication (
    auth_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    auth_token VARCHAR(255) NOT NULL,
    auth_method VARCHAR(50) NOT NULL,
    issued_at DATETIME NOT NULL DEFAULT GETDATE(),
    expires_at DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);


-- PART 2: 3 CONSTRAINTS


-- Ensure that the balance in the Account table is always greater than or equal to zero. Exception for credit cards and loans.
ALTER TABLE Account
ADD CONSTRAINT chk_account_balance_nonnegative
CHECK (
    (balance >= 0) OR
    (account_type IN ('Credit Card', 'Loan') AND balance <= 0)
);

-- Ensure that the amount in the Transactions table is not zero.
ALTER TABLE Transactions
ADD CONSTRAINT chk_transaction_amount_nonzero
CHECK (amount <> 0);

-- Ensure that the current_progress in the Financial_Goal table does not exceed the target_amount. 
ALTER TABLE Financial_Goal
ADD CONSTRAINT chk_financial_goal_progress
CHECK (current_progress <= target_amount);


-- PART 3: DATA INSERT

INSERT INTO Users (username, password_hash, created_at, updated_at)
VALUES
('alice', 'hash_password1', GETDATE(), GETDATE()),
('bob', 'hash_password2', GETDATE(), GETDATE()),
('charlie', 'hash_password3', GETDATE(), GETDATE()),
('david', 'hash_password4', GETDATE(), GETDATE()),
('eve', 'hash_password5', GETDATE(), GETDATE()),
('frank', 'hash_password6', GETDATE(), GETDATE()),
('grace', 'hash_password7', GETDATE(), GETDATE()),
('heidi', 'hash_password8', GETDATE(), GETDATE()),
('ivan', 'hash_password9', GETDATE(), GETDATE()),
('judy', 'hash_password10', GETDATE(), GETDATE()),
('kim', 'hash_password11', GETDATE(), GETDATE()),
('leo', 'hash_password12', GETDATE(), GETDATE()),
('mike', 'hash_password13', GETDATE(), GETDATE()),
('nancy', 'hash_password14', GETDATE(), GETDATE()),
('oliver', 'hash_password15', GETDATE(), GETDATE()),
('peggy', 'hash_password16', GETDATE(), GETDATE()),
('quincy', 'hash_password17', GETDATE(), GETDATE()),
('rachel', 'hash_password18', GETDATE(), GETDATE()),
('sam', 'hash_password19', GETDATE(), GETDATE()),
('trent', 'hash_password20', GETDATE(), GETDATE()),
('ursula', 'hash_password21', GETDATE(), GETDATE()),
('victor', 'hash_password22', GETDATE(), GETDATE()),
('wendy', 'hash_password23', GETDATE(), GETDATE()),
('xavier', 'hash_password24', GETDATE(), GETDATE()),
('yvonne', 'hash_password25', GETDATE(), GETDATE()),
('zach', 'hash_password26', GETDATE(), GETDATE()),
('amy', 'hash_password27', GETDATE(), GETDATE()),
('brian', 'hash_password28', GETDATE(), GETDATE()),
('cindy', 'hash_password29', GETDATE(), GETDATE()),
('doug', 'hash_password30', GETDATE(), GETDATE()),
('emily', 'hash_password31', GETDATE(), GETDATE()),
('fred', 'hash_password32', GETDATE(), GETDATE()),
('gina', 'hash_password33', GETDATE(), GETDATE()),
('harry', 'hash_password34', GETDATE(), GETDATE()),
('irene', 'hash_password35', GETDATE(), GETDATE());

INSERT INTO Financial_Institution (institution_name, address, contact_info)
VALUES
('Synchrony Bank', '170 West Election Road, Draper, UT', '1-866-226-5638'),
('Barclays Bank', '745 Seventh Avenue, New York, NY', '1-888-710-8756'),
('Discover Bank', '502 E. Market Street, Greenwood, DE', '1-800-347-7000'),
('American Express Bank', '4315 S 2700 W, Salt Lake City, UT', '1-800-528-4800'),
('Morgan Stanley Bank', '1585 Broadway, New York, NY', '1-888-454-3965'),
('Goldman Sachs Bank', '200 West Street, New York, NY', '1-212-902-1000'),
('State Street Bank', '1 Lincoln Street, Boston, MA', '1-617-786-3000'),
('Northern Trust Bank', '50 S La Salle St, Chicago, IL', '1-312-630-6000'),
('BMO Harris Bank', '111 W Monroe St, Chicago, IL', '1-888-340-2265'),
('Silicon Valley Bank', '3003 Tasman Drive, Santa Clara, CA', '1-408-654-7400'),
('First Republic Bank', '111 Pine Street, San Francisco, CA', '1-888-408-0288'),
('Signature Bank', '565 Fifth Avenue, New York, NY', '1-646-822-1500'),
('Comerica Bank', '1717 Main Street, Dallas, TX', '1-800-266-3742'),
('Bank of the West', '180 Montgomery St, San Francisco, CA', '1-800-488-2265'),
('First Citizens Bank', '4300 Six Forks Road, Raleigh, NC', '1-888-323-4732'),
('East West Bank', '135 N. Los Robles Ave, Pasadena, CA', '1-888-895-5650'),
('Banco Popular', '85 Broad Street, New York, NY', '1-800-377-0800'),
('First National Bank', '1620 Dodge St, Omaha, NE', '1-800-642-0014'),
('Zions Bank', '1 S Main St, Salt Lake City, UT', '1-888-307-3411'),
('BankUnited', '14817 Oak Lane, Miami Lakes, FL', '1-877-779-2265'),
('Cathay Bank', '777 N Broadway, Los Angeles, CA', '1-800-922-8429'),
('Webster Bank', '145 Bank Street, Waterbury, CT', '1-800-325-2424'),
('City National Bank', '555 S Flower St, Los Angeles, CA', '1-800-773-7100'),
('UMB Bank', '1010 Grand Blvd, Kansas City, MO', '1-800-860-4862'),
('CIBC Bank USA', '120 S LaSalle St, Chicago, IL', '1-877-448-6500'),
('Valley National Bank', '1455 Valley Road, Wayne, NJ', '1-800-522-4100'),
('Customers Bank', '99 Bridge Street, Phoenixville, PA', '1-866-476-2265'),
('Texas Capital Bank', '2000 McKinney Ave, Dallas, TX', '1-877-839-2265'),
('Pinnacle Bank', '150 3rd Ave S, Nashville, TN', '1-800-264-3613'),
('Cadence Bank', '1349 W Peachtree St NW, Atlanta, GA', '1-800-636-7622'),
('FirstBank', '12345 W Colfax Ave, Lakewood, CO', '1-800-964-3444'),
('Bank OZK', '18000 Cantrell Rd, Little Rock, AR', '1-800-274-4482'),
('BOK Financial', 'One Williams Center, Tulsa, OK', '1-800-234-6181'),
('Old National Bank', '1 Main St, Evansville, IN', '1-800-731-2265'),
('South State Bank', '1101 First Street South, Winter Haven, FL', '1-800-277-2175');


INSERT INTO Category (category_name, description)
VALUES
('Groceries', 'Food and household supplies'),
('Rent', 'Monthly apartment or house rent'),
('Utilities', 'Electricity, water, gas bills'),
('Transportation', 'Public transit, fuel, car maintenance'),
('Entertainment', 'Movies, concerts, events'),
('Dining Out', 'Restaurants and cafes'),
('Healthcare', 'Medical expenses and medications'),
('Education', 'Tuition and school supplies'),
('Insurance', 'Health, auto, home insurance'),
('Clothing', 'Apparel and accessories'),
('Personal Care', 'Haircuts, salon visits, grooming'),
('Travel', 'Airfare, hotels, vacation expenses'),
('Savings', 'Money set aside for savings'),
('Investments', 'Stocks, bonds, mutual funds'),
('Gifts', 'Presents for others'),
('Charity', 'Donations to charitable organizations'),
('Taxes', 'Income and property taxes'),
('Pets', 'Pet food, vet bills'),
('Subscriptions', 'Magazines, streaming services'),
('Miscellaneous', 'Other uncategorized expenses'),
('Home Maintenance', 'Repairs and upkeep of home'),
('Childcare', 'Daycare, babysitters'),
('Loan Payments', 'Student loans, personal loans'),
('Credit Card Payments', 'Paying off credit card debt'),
('Phone', 'Mobile phone bills'),
('Internet', 'Home internet services'),
('Gym Membership', 'Fitness club fees'),
('Alcohol & Bars', 'Drinks and nightlife'),
('Electronics', 'Gadgets and devices'),
('Office Supplies', 'Work-related materials'),
('Books', 'Physical and digital books'),
('Hobbies', 'Expenses for hobbies and crafts'),
('Parking', 'Parking fees and permits'),
('ATM Fees', 'Fees for ATM withdrawals'),
('Fines', 'Traffic tickets and penalties');


INSERT INTO Account (user_id, institution_id, account_type, balance, created_at)
VALUES
(1, 1, 'Checking', 1500.00, GETDATE()),
(1, 2, 'Savings', 5000.00, GETDATE()),
(2, 3, 'Checking', 1200.00, GETDATE()),
(3, 4, 'Savings', 8000.00, GETDATE()),
(4, 5, 'Credit Card', -200.00, GETDATE()),
(5, 6, 'Checking', 3000.00, GETDATE()),
(6, 7, 'Savings', 4500.00, GETDATE()),
(7, 8, 'Investment', 10000.00, GETDATE()),
(8, 9, 'Checking', 900.00, GETDATE()),
(9, 10, 'Savings', 7500.00, GETDATE()),
(10, 11, 'Checking', 600.00, GETDATE()),
(11, 12, 'Savings', 6500.00, GETDATE()),
(12, 13, 'Checking', 1100.00, GETDATE()),
(13, 14, 'Savings', 2000.00, GETDATE()),
(14, 15, 'Credit Card', -500.00, GETDATE()),
(15, 16, 'Checking', 2500.00, GETDATE()),
(16, 17, 'Savings', 7000.00, GETDATE()),
(17, 18, 'Investment', 15000.00, GETDATE()),
(18, 19, 'Checking', 1300.00, GETDATE()),
(19, 20, 'Savings', 5500.00, GETDATE()),
(20, 1, 'Checking', 800.00, GETDATE()),
(21, 2, 'Savings', 6000.00, GETDATE()),
(22, 3, 'Checking', 1400.00, GETDATE()),
(23, 4, 'Savings', 8500.00, GETDATE()),
(24, 5, 'Credit Card', -300.00, GETDATE()),
(25, 6, 'Checking', 3200.00, GETDATE()),
(26, 7, 'Savings', 4800.00, GETDATE()),
(27, 8, 'Investment', 11000.00, GETDATE()),
(28, 9, 'Checking', 950.00, GETDATE()),
(29, 10, 'Savings', 7800.00, GETDATE()),
(30, 11, 'Checking', 650.00, GETDATE()),
(31, 12, 'Savings', 6700.00, GETDATE()),
(32, 13, 'Checking', 1150.00, GETDATE()),
(33, 14, 'Savings', 2100.00, GETDATE()),
(34, 15, 'Credit Card', -450.00, GETDATE()),
(35, 16, 'Checking', 2700.00, GETDATE());


DECLARE @StartDate DATE = DATEADD(MONTH, -1, GETDATE());
DECLARE @EndDate DATE = GETDATE();

INSERT INTO Transactions (account_id, amount, transaction_date, description)
VALUES
(1, -50.00, DATEADD(DAY, -1, @EndDate), 'Groceries at Supermarket'),
(1, -120.00, DATEADD(DAY, -3, @EndDate), 'Utility Bill Payment'),
(1, 500.00, DATEADD(DAY, -5, @EndDate), 'Paycheck Deposit'),
(2, -200.00, DATEADD(DAY, -2, @EndDate), 'Dining Out'),
(2, 150.00, DATEADD(DAY, -10, @EndDate), 'Transfer from Checking'),
(3, -75.00, DATEADD(DAY, -1, @EndDate), 'Gas Station'),
(3, -40.00, DATEADD(DAY, -4, @EndDate), 'Movie Tickets'),
(3, 1200.00, DATEADD(DAY, -15, @EndDate), 'Paycheck Deposit'),
(4, -500.00, DATEADD(DAY, -5, @EndDate), 'Rent Payment'),
(4, 300.00, DATEADD(DAY, -20, @EndDate), 'Transfer from Savings'),
(5, -100.00, DATEADD(DAY, -2, @EndDate), 'Credit Card Payment'),
(5, -50.00, DATEADD(DAY, -7, @EndDate), 'Online Shopping'),
(6, -60.00, DATEADD(DAY, -1, @EndDate), 'Dinner at Restaurant'),
(6, 3000.00, DATEADD(DAY, -15, @EndDate), 'Paycheck Deposit'),
(7, -150.00, DATEADD(DAY, -3, @EndDate), 'Electronics Purchase'),
(7, 200.00, DATEADD(DAY, -10, @EndDate), 'Interest Earned'),
(8, 500.00, DATEADD(DAY, -5, @EndDate), 'Dividend Payment'),
(8, -200.00, DATEADD(DAY, -12, @EndDate), 'Stock Purchase'),
(9, -80.00, DATEADD(DAY, -2, @EndDate), 'Clothing Store'),
(9, 900.00, DATEADD(DAY, -14, @EndDate), 'Paycheck Deposit'),
(10, -100.00, DATEADD(DAY, -1, @EndDate), 'Grocery Shopping'),
(10, 7500.00, DATEADD(DAY, -30, @EndDate), 'Bonus Deposit'),
(11, -30.00, DATEADD(DAY, -3, @EndDate), 'Coffee Shop'),
(11, 600.00, DATEADD(DAY, -16, @EndDate), 'Paycheck Deposit'),
(12, -120.00, DATEADD(DAY, -2, @EndDate), 'Utility Bills'),
(12, 6500.00, DATEADD(DAY, -25, @EndDate), 'Investment Return'),
(13, -50.00, DATEADD(DAY, -1, @EndDate), 'Gym Membership'),
(13, 1100.00, DATEADD(DAY, -10, @EndDate), 'Paycheck Deposit'),
(14, -200.00, DATEADD(DAY, -5, @EndDate), 'Credit Card Payment'),
(14, -300.00, DATEADD(DAY, -20, @EndDate), 'Online Shopping'),
(15, -90.00, DATEADD(DAY, -2, @EndDate), 'Fuel Purchase'),
(15, 2500.00, DATEADD(DAY, -15, @EndDate), 'Paycheck Deposit'),
(16, -100.00, DATEADD(DAY, -1, @EndDate), 'Medical Expenses'),
(16, 7000.00, DATEADD(DAY, -27, @EndDate), 'Investment Return'),
(17, 600.00, DATEADD(DAY, -3, @EndDate), 'Interest Earned'),
(17, -500.00, DATEADD(DAY, -8, @EndDate), 'Stock Purchase'),
(18, -70.00, DATEADD(DAY, -2, @EndDate), 'Fast Food'),
(18, 1300.00, DATEADD(DAY, -12, @EndDate), 'Paycheck Deposit'),
(19, -150.00, DATEADD(DAY, -1, @EndDate), 'Pet Supplies'),
(19, 5500.00, DATEADD(DAY, -22, @EndDate), 'Bonus Deposit'),
(20, -45.00, DATEADD(DAY, -4, @EndDate), 'Parking Fees'),
(20, 800.00, DATEADD(DAY, -18, @EndDate), 'Paycheck Deposit'),
(21, -110.00, DATEADD(DAY, -2, @EndDate), 'Restaurant'),
(21, 6000.00, DATEADD(DAY, -20, @EndDate), 'Investment Return'),
(22, -65.00, DATEADD(DAY, -1, @EndDate), 'Movie Tickets'),
(22, 1400.00, DATEADD(DAY, -15, @EndDate), 'Paycheck Deposit'),
(23, -550.00, DATEADD(DAY, -5, @EndDate), 'Rent Payment'),
(23, 8500.00, DATEADD(DAY, -30, @EndDate), 'Bonus Deposit'),
(24, -80.00, DATEADD(DAY, -2, @EndDate), 'Credit Card Payment'),
(24, -220.00, DATEADD(DAY, -10, @EndDate), 'Online Shopping'),
(25, -95.00, DATEADD(DAY, -1, @EndDate), 'Grocery Store'),
(25, 3200.00, DATEADD(DAY, -17, @EndDate), 'Paycheck Deposit'),
(26, -130.00, DATEADD(DAY, -3, @EndDate), 'Utility Bills'),
(26, 4800.00, DATEADD(DAY, -25, @EndDate), 'Investment Return'),
(27, 700.00, DATEADD(DAY, -5, @EndDate), 'Dividend Payment'),
(27, -300.00, DATEADD(DAY, -15, @EndDate), 'Stock Purchase'),
(28, -55.00, DATEADD(DAY, -2, @EndDate), 'Coffee Shop'),
(28, 950.00, DATEADD(DAY, -12, @EndDate), 'Paycheck Deposit'),
(29, -85.00, DATEADD(DAY, -1, @EndDate), 'Fuel'),
(29, 7800.00, DATEADD(DAY, -28, @EndDate), 'Bonus Deposit'),
(30, -40.00, DATEADD(DAY, -3, @EndDate), 'Streaming Subscription'),
(30, 650.00, DATEADD(DAY, -14, @EndDate), 'Paycheck Deposit'),
(31, -115.00, DATEADD(DAY, -2, @EndDate), 'Gym Membership'),
(31, 6700.00, DATEADD(DAY, -26, @EndDate), 'Investment Return'),
(32, -60.00, DATEADD(DAY, -1, @EndDate), 'Dining Out'),
(32, 1150.00, DATEADD(DAY, -16, @EndDate), 'Paycheck Deposit'),
(33, -210.00, DATEADD(DAY, -5, @EndDate), 'Clothing Store'),
(33, 2100.00, DATEADD(DAY, -18, @EndDate), 'Paycheck Deposit'),
(34, -150.00, DATEADD(DAY, -2, @EndDate), 'Credit Card Payment'),
(34, -300.00, DATEADD(DAY, -9, @EndDate), 'Online Shopping'),
(35, -70.00, DATEADD(DAY, -1, @EndDate), 'Grocery Shopping'),
(35, 2700.00, DATEADD(DAY, -20, @EndDate), 'Paycheck Deposit');


INSERT INTO Budget (user_id, account_id, category_id, amount, start_date, end_date)
VALUES
(1, 1, 1, 500.00, '2023-01-01', '2023-12-31'),
(2, 3, 2, 1200.00, '2023-01-01', '2023-12-31'),
(3, 5, 3, 150.00, '2023-01-01', '2023-12-31'),
(4, 7, 4, 200.00, '2023-01-01', '2023-12-31'),
(5, 9, 5, 300.00, '2023-01-01', '2023-12-31'),
(6, 11, 6, 250.00, '2023-01-01', '2023-12-31'),
(7, 13, 7, 100.00, '2023-01-01', '2023-12-31'),
(8, 15, 8, 400.00, '2023-01-01', '2023-12-31'),
(9, 17, 9, 350.00, '2023-01-01', '2023-12-31'),
(10, 19, 10, 220.00, '2023-01-01', '2023-12-31'),
(11, 21, 11, 180.00, '2023-01-01', '2023-12-31'),
(12, 23, 12, 600.00, '2023-01-01', '2023-12-31'),
(13, 25, 13, 700.00, '2023-01-01', '2023-12-31'),
(14, 27, 14, 270.00, '2023-01-01', '2023-12-31'),
(15, 29, 15, 320.00, '2023-01-01', '2023-12-31'),
(16, 31, 16, 410.00, '2023-01-01', '2023-12-31'),
(17, 33, 17, 90.00, '2023-01-01', '2023-12-31'),
(18, 2, 18, 130.00, '2023-01-01', '2023-12-31'),
(19, 4, 19, 80.00, '2023-01-01', '2023-12-31'),
(20, 6, 20, 260.00, '2023-01-01', '2023-12-31'),
(21, 8, 21, 230.00, '2023-01-01', '2023-12-31'),
(22, 10, 22, 500.00, '2023-01-01', '2023-12-31'),
(23, 12, 23, 120.00, '2023-01-01', '2023-12-31'),
(24, 14, 24, 140.00, '2023-01-01', '2023-12-31'),
(25, 16, 25, 350.00, '2023-01-01', '2023-12-31'),
(26, 18, 26, 190.00, '2023-01-01', '2023-12-31'),
(27, 20, 27, 60.00, '2023-01-01', '2023-12-31'),
(28, 22, 28, 220.00, '2023-01-01', '2023-12-31'),
(29, 24, 29, 330.00, '2023-01-01', '2023-12-31'),
(30, 26, 30, 440.00, '2023-01-01', '2023-12-31'),
(31, 28, 31, 550.00, '2023-01-01', '2023-12-31'),
(32, 30, 32, 660.00, '2023-01-01', '2023-12-31'),
(33, 32, 33, 770.00, '2023-01-01', '2023-12-31'),
(34, 34, 34, 880.00, '2023-01-01', '2023-12-31'),
(35, 35, 35, 990.00, '2023-01-01', '2023-12-31');


INSERT INTO Expense (budget_id, amount, expense_date, description)
VALUES
-- Expenses for Budget ID 1
(1, 45.00, '2023-01-05', 'Groceries at Market'),
(1, 60.00, '2023-01-15', 'Supermarket Purchase'),
(1, 55.00, '2023-01-25', 'Farmers Market'),
(1, 50.00, '2023-02-05', 'Grocery Store'),
(1, 65.00, '2023-02-15', 'Supermarket Purchase'),
-- Expenses for Budget ID 2
(2, 1200.00, '2023-01-01', 'January Rent'),
(2, 1200.00, '2023-02-01', 'February Rent'),
(2, 1200.00, '2023-03-01', 'March Rent'),
-- Expenses for Budget ID 3
(3, 50.00, '2023-01-10', 'Electricity Bill'),
(3, 30.00, '2023-01-15', 'Water Bill'),
(3, 40.00, '2023-01-20', 'Gas Bill'),
-- Expenses for Budget ID 4
(4, 25.00, '2023-01-08', 'Bus Pass'),
(4, 40.00, '2023-01-18', 'Gasoline'),
(4, 35.00, '2023-01-28', 'Car Maintenance'),
-- Expenses for Budget ID 5
(5, 80.00, '2023-01-12', 'Concert Tickets'),
(5, 50.00, '2023-01-22', 'Movie Night'),
(5, 70.00, '2023-01-29', 'Theater Show'),
-- Expenses for Budget ID 6
(6, 45.00, '2023-01-05', 'Dinner at Restaurant'),
(6, 60.00, '2023-01-15', 'Lunch at Cafe'),
(6, 50.00, '2023-01-25', 'Coffee Shop'),
-- Continue adding expenses for other budgets up to Budget ID 35
-- Example for Budget ID 7
(7, 30.00, '2023-01-07', 'Pharmacy Purchase'),
(7, 100.00, '2023-01-17', 'Doctor Appointment'),
(7, 20.00, '2023-01-27', 'Medical Supplies'),
-- Expenses for Budget ID 8
(8, 500.00, '2023-01-09', 'Tuition Payment'),
(8, 60.00, '2023-01-19', 'Books and Supplies'),
(8, 40.00, '2023-01-29', 'Online Course'),
-- Continue up to Budget ID 35
(35, 150.00, '2023-01-10', 'Miscellaneous Expenses'),
(35, 200.00, '2023-02-10', 'Miscellaneous Expenses'),
(35, 180.00, '2023-03-10', 'Miscellaneous Expenses');


INSERT INTO Financial_Goal (user_id, account_id, target_amount, current_progress, start_date, end_date)
VALUES
(1, 1, 10000.00, 2000.00, '2023-01-01', '2023-12-31'),
(2, 3, 5000.00, 1500.00, '2023-01-01', '2023-12-31'),
(3, 5, 8000.00, 3000.00, '2023-01-01', '2023-12-31'),
(4, 7, 6000.00, 2500.00, '2023-01-01', '2023-12-31'),
(5, 9, 12000.00, 4000.00, '2023-01-01', '2023-12-31'),
(6, 11, 7000.00, 3500.00, '2023-01-01', '2023-12-31'),
(7, 13, 9000.00, 4500.00, '2023-01-01', '2023-12-31'),
(8, 15, 11000.00, 5500.00, '2023-01-01', '2023-12-31'),
(9, 17, 13000.00, 6500.00, '2023-01-01', '2023-12-31'),
(10, 19, 15000.00, 7500.00, '2023-01-01', '2023-12-31'),
(11, 21, 16000.00, 8000.00, '2023-01-01', '2023-12-31'),
(12, 23, 14000.00, 7000.00, '2023-01-01', '2023-12-31'),
(13, 25, 12000.00, 6000.00, '2023-01-01', '2023-12-31'),
(14, 27, 10000.00, 5000.00, '2023-01-01', '2023-12-31'),
(15, 29, 8000.00, 4000.00, '2023-01-01', '2023-12-31'),
(16, 31, 6000.00, 3000.00, '2023-01-01', '2023-12-31'),
(17, 33, 4000.00, 2000.00, '2023-01-01', '2023-12-31'),
(18, 2, 5000.00, 2500.00, '2023-01-01', '2023-12-31'),
(19, 4, 7000.00, 3500.00, '2023-01-01', '2023-12-31'),
(20, 6, 9000.00, 4500.00, '2023-01-01', '2023-12-31'),
(21, 8, 11000.00, 5500.00, '2023-01-01', '2023-12-31'),
(22, 10, 13000.00, 6500.00, '2023-01-01', '2023-12-31'),
(23, 12, 15000.00, 7500.00, '2023-01-01', '2023-12-31'),
(24, 14, 16000.00, 8000.00, '2023-01-01', '2023-12-31'),
(25, 16, 14000.00, 7000.00, '2023-01-01', '2023-12-31'),
(26, 18, 12000.00, 6000.00, '2023-01-01', '2023-12-31'),
(27, 20, 10000.00, 5000.00, '2023-01-01', '2023-12-31'),
(28, 22, 8000.00, 4000.00, '2023-01-01', '2023-12-31'),
(29, 24, 6000.00, 3000.00, '2023-01-01', '2023-12-31'),
(30, 26, 4000.00, 2000.00, '2023-01-01', '2023-12-31'),
(31, 28, 5000.00, 2500.00, '2023-01-01', '2023-12-31'),
(32, 30, 7000.00, 3500.00, '2023-01-01', '2023-12-31'),
(33, 32, 9000.00, 4500.00, '2023-01-01', '2023-12-31'),
(34, 34, 11000.00, 5500.00, '2023-01-01', '2023-12-31'),
(35, 35, 13000.00, 6500.00, '2023-01-01', '2023-12-31');



INSERT INTO Milestone (goal_id, milestone_amount, reached_date)
VALUES
-- Milestones for Goal ID 1
(1, 2500.00, '2023-02-01'),
(1, 5000.00, '2023-04-01'),
(1, 7500.00, NULL), -- Not yet reached
(1, 10000.00, NULL), -- Final milestone

-- Milestones for Goal ID 2
(2, 1250.00, '2023-03-01'),
(2, 2500.00, '2023-06-01'),
(2, 3750.00, NULL),
(2, 5000.00, NULL),

-- Milestones for Goal ID 3
(3, 2000.00, '2023-02-15'),
(3, 4000.00, '2023-05-15'),
(3, 6000.00, NULL),
(3, 8000.00, NULL),

-- Milestones for Goal ID 4
(4, 1500.00, '2023-01-20'),
(4, 3000.00, '2023-04-20'),
(4, 4500.00, NULL),
(4, 6000.00, NULL),

-- Milestones for Goal IDs 5 to 35
(5, 3000.00, '2023-03-05'), 
(5, 6000.00, NULL), 
(5, 9000.00, NULL), 
(5, 12000.00, NULL),
(6, 1750.00, '2023-02-10'), 
(6, 3500.00, NULL), 
(6, 5250.00, NULL), 
(6, 7000.00, NULL),
(7, 2250.00, '2023-03-12'), 
(7, 4500.00, NULL), 
(7, 6750.00, NULL), 
(7, 9000.00, NULL),
(8, 2750.00, '2023-04-18'), 
(8, 5500.00, NULL), 
(8, 8250.00, NULL), 
(8, 11000.00, NULL),
(9, 3250.00, '2023-05-22'), 
(9, 6500.00, NULL), 
(9, 9750.00, NULL), 
(9, 13000.00, NULL),
(10, 3750.00, '2023-06-30'), 
(10, 7500.00, NULL), 
(10, 11250.00, NULL), 
(10, 15000.00, NULL),
(35, 3250.00, '2023-06-01'),
(35, 6500.00, NULL),
(35, 9750.00, NULL),
(35, 13000.00, NULL);

INSERT INTO Notification (user_id, message, sent_date, type)
VALUES
-- Notifications for User ID 1
(1, 'Milestone reached: $2,500!', '2023-02-01', 'Milestone'),
(1, 'Budget exceeded for Groceries', '2023-02-05', 'Budget Alert'),
(1, 'New login from unrecognized device', '2023-02-10', 'Security Alert'),

-- Notifications for User ID 2
(2, 'Milestone reached: $1,250!', '2023-03-01', 'Milestone'),
(2, 'Budget exceeded for Rent', '2023-03-02', 'Budget Alert'),
(2, 'Monthly statement is ready', '2023-03-05', 'Statement'),

-- Notifications for User ID 3
(3, 'Milestone reached: $2,000!', '2023-02-15', 'Milestone'),
(3, 'Password changed successfully', '2023-02-20', 'Security Update'),
(3, 'Budget exceeded for Utilities', '2023-02-25', 'Budget Alert'),

-- Notifications for User IDs 4 to 35
(4, 'Milestone reached: $1,500!', '2023-01-20', 'Milestone'),
(4, 'Unusual activity detected', '2023-01-25', 'Security Alert'),
(5, 'Milestone reached: $3,000!', '2023-03-05', 'Milestone'),
(5, 'Budget exceeded for Entertainment', '2023-03-10', 'Budget Alert'),
(6, 'Milestone reached: $1,750!', '2023-02-10', 'Milestone'),
(6, 'New device logged in', '2023-02-15', 'Security Alert'),
(35, 'Milestone reached: $3,250!', '2023-06-01', 'Milestone'),
(35, 'Budget exceeded for Miscellaneous', '2023-06-05', 'Budget Alert'),
(35, 'Monthly statement is ready', '2023-06-10', 'Statement');


INSERT INTO Transaction_Category (transaction_id, category_id)
VALUES
(1, 1), -- Transaction 1: Groceries
(1, 6), -- Transaction 1 also tagged as Dining Out
(2, 2), -- Transaction 2: Rent
(3, 4), -- Transaction 3: Transportation
(4, 5), -- Transaction 4: Entertainment
(5, 6), -- Transaction 5: Dining Out
(6, 4), -- Transaction 6: Transportation
(7, 5), -- Transaction 7: Entertainment
(8, 1), -- Transaction 8: Groceries
(9, 2), -- Transaction 9: Rent

(10, 3), -- Transaction 10: Utilities
(11, 10), -- Transaction 11: Clothing
(12, 6), -- Transaction 12: Dining Out
(13, 1), -- Transaction 13: Groceries
(14, 4), -- Transaction 14: Transportation
(15, 7), -- Transaction 15: Healthcare
(16, 9), -- Transaction 16: Insurance
(17, 8), -- Transaction 17: Education
(18, 12), -- Transaction 18: Travel
(19, 11), -- Transaction 19: Personal Care

(20, 13), -- Transaction 20: Savings
(21, 14), -- Transaction 21: Investments
(22, 5), -- Transaction 22: Entertainment
(23, 2), -- Transaction 23: Rent
(24, 15), -- Transaction 24: Gifts
(25, 1), -- Transaction 25: Groceries
(26, 3), -- Transaction 26: Utilities
(27, 6), -- Transaction 27: Dining Out
(28, 16), -- Transaction 28: Charity
(29, 17), -- Transaction 29: Taxes

(30, 4), -- Transaction 30: Transportation
(31, 18), -- Transaction 31: Pets
(32, 19), -- Transaction 32: Subscriptions
(33, 1), -- Transaction 33: Groceries
(34, 2), -- Transaction 34: Rent
(35, 20), -- Transaction 35: Miscellaneous
(36, 21), -- Transaction 36: Home Maintenance
(37, 22), -- Transaction 37: Childcare
(38, 23), -- Transaction 38: Loan Payments
(39, 24), -- Transaction 39: Credit Card Payments
(40, 25), -- Transaction 40: Phone

(41, 26), -- Transaction 41: Internet
(42, 27), -- Transaction 42: Gym Membership
(43, 28), -- Transaction 43: Alcohol & Bars
(44, 29), -- Transaction 44: Electronics
(45, 30), -- Transaction 45: Office Supplies
(46, 31), -- Transaction 46: Books
(47, 32), -- Transaction 47: Hobbies
(48, 33), -- Transaction 48: Parking
(49, 34), -- Transaction 49: ATM Fees
(50, 35), -- Transaction 50: Fines

(51, 1), (51, 4), -- Transaction 51: Groceries and Transportation
(52, 5), (52, 6), -- Transaction 52: Entertainment and Dining Out
(53, 2), (53, 3), -- Transaction 53: Rent and Utilities
(54, 7), (54, 9), -- Transaction 54: Healthcare and Insurance
(55, 12), (55, 18), -- Transaction 55: Travel and Pets
(56, 10), (56, 11), -- Transaction 56: Clothing and Personal Care
(57, 13), (57, 14), -- Transaction 57: Savings and Investments
(58, 16), (58, 15), -- Transaction 58: Charity and Gifts
(59, 17), (59, 34), -- Transaction 59: Taxes and ATM Fees
(60, 19), (60, 20), -- Transaction 60: Subscriptions and Miscellaneous

(61, 2),
(62, 1),
(63, 5),
(64, 6),
(65, 4),
(66, 3),
(67, 7),
(68, 8),
(69, 9),
(70, 10);


INSERT INTO Plaid_Integration (user_id, institution_id, access_token, item_id)
VALUES
(1, 1, 'access_token_1', 'item_id_1'),
(2, 3, 'access_token_2', 'item_id_2'),
(3, 5, 'access_token_3', 'item_id_3'),
(4, 7, 'access_token_4', 'item_id_4'),
(5, 9, 'access_token_5', 'item_id_5'),
(6, 11, 'access_token_6', 'item_id_6'),
(7, 13, 'access_token_7', 'item_id_7'),
(8, 15, 'access_token_8', 'item_id_8'),
(9, 17, 'access_token_9', 'item_id_9'),
(10, 19, 'access_token_10', 'item_id_10'),
(11, 21, 'access_token_11', 'item_id_11'),
(12, 23, 'access_token_12', 'item_id_12'),
(13, 25, 'access_token_13', 'item_id_13'),
(14, 27, 'access_token_14', 'item_id_14'),
(15, 29, 'access_token_15', 'item_id_15'),
(16, 31, 'access_token_16', 'item_id_16'),
(17, 33, 'access_token_17', 'item_id_17'),
(18, 2, 'access_token_18', 'item_id_18'),
(19, 4, 'access_token_19', 'item_id_19'),
(20, 6, 'access_token_20', 'item_id_20'),
(21, 8, 'access_token_21', 'item_id_21'),
(22, 10, 'access_token_22', 'item_id_22'),
(23, 12, 'access_token_23', 'item_id_23'),
(24, 14, 'access_token_24', 'item_id_24'),
(25, 16, 'access_token_25', 'item_id_25'),
(26, 18, 'access_token_26', 'item_id_26'),
(27, 20, 'access_token_27', 'item_id_27'),
(28, 22, 'access_token_28', 'item_id_28'),
(29, 24, 'access_token_29', 'item_id_29'),
(30, 26, 'access_token_30', 'item_id_30'),
(31, 28, 'access_token_31', 'item_id_31'),
(32, 30, 'access_token_32', 'item_id_32'),
(33, 32, 'access_token_33', 'item_id_33'),
(34, 34, 'access_token_34', 'item_id_34'),
(35, 35, 'access_token_35', 'item_id_35');


INSERT INTO User_Authentication (user_id, auth_token, auth_method, issued_at, expires_at)
VALUES
(1, 'auth_token_1', 'Password', '2023-01-01', '2024-01-01'),
(2, 'auth_token_2', 'Password', '2023-01-02', '2024-01-02'),
(3, 'auth_token_3', 'Password', '2023-01-03', '2024-01-03'),
(4, 'auth_token_4', 'Password', '2023-01-04', '2024-01-04'),
(5, 'auth_token_5', 'Password', '2023-01-05', '2024-01-05'),
(6, 'auth_token_6', 'Password', '2023-01-06', '2024-01-06'),
(7, 'auth_token_7', 'Password', '2023-01-07', '2024-01-07'),
(8, 'auth_token_8', 'Password', '2023-01-08', '2024-01-08'),
(9, 'auth_token_9', 'Password', '2023-01-09', '2024-01-09'),
(10, 'auth_token_10', 'Password', '2023-01-10', '2024-01-10'),
(11, 'auth_token_11', 'Password', '2023-01-11', '2024-01-11'),
(12, 'auth_token_12', 'Password', '2023-01-12', '2024-01-12'),
(13, 'auth_token_13', 'Password', '2023-01-13', '2024-01-13'),
(14, 'auth_token_14', 'Password', '2023-01-14', '2024-01-14'),
(15, 'auth_token_15', 'Password', '2023-01-15', '2024-01-15'),
(16, 'auth_token_16', 'Password', '2023-01-16', '2024-01-16'),
(17, 'auth_token_17', 'Password', '2023-01-17', '2024-01-17'),
(18, 'auth_token_18', 'Password', '2023-01-18', '2024-01-18'),
(19, 'auth_token_19', 'Password', '2023-01-19', '2024-01-19'),
(20, 'auth_token_20', 'Password', '2023-01-20', '2024-01-20'),
(21, 'auth_token_21', 'Password', '2023-01-21', '2024-01-21'),
(22, 'auth_token_22', 'Password', '2023-01-22', '2024-01-22'),
(23, 'auth_token_23', 'Password', '2023-01-23', '2024-01-23'),
(24, 'auth_token_24', 'Password', '2023-01-24', '2024-01-24'),
(25, 'auth_token_25', 'Password', '2023-01-25', '2024-01-25'),
(26, 'auth_token_26', 'Password', '2023-01-26', '2024-01-26'),
(27, 'auth_token_27', 'Password', '2023-01-27', '2024-01-27'),
(28, 'auth_token_28', 'Password', '2023-01-28', '2024-01-28'),
(29, 'auth_token_29', 'Password', '2023-01-29', '2024-01-29'),
(30, 'auth_token_30', 'Password', '2023-01-30', '2024-01-30'),
(31, 'auth_token_31', 'Password', '2023-01-31', '2024-01-31'),
(32, 'auth_token_32', 'Password', '2023-02-01', '2024-02-01'),
(33, 'auth_token_33', 'Password', '2023-02-02', '2024-02-02'),
(34, 'auth_token_34', 'Password', '2023-02-03', '2024-02-03'),
(35, 'auth_token_35', 'Password', '2023-02-04', '2024-02-04');


-- PART 4: Aggregate, Joins, Subqueries

PRINT 'Total Balance Across All Accounts';

SELECT SUM(balance) AS TotalBalance
FROM Account;



PRINT 'Average Account Balance Per User';

SELECT 
    user_id,
    AVG(balance) AS AverageBalance
FROM Account
GROUP BY user_id;



PRINT 'Users with Accounts Above Average Balance';

SELECT 
    u.username,
    a.balance
FROM Users u
JOIN Account a ON u.user_id = a.user_id
WHERE a.balance > (
    SELECT AVG(balance) FROM Account
)
GROUP BY u.username, a.balance;


PRINT 'Transactions Above Average Amount';

SELECT 
    t.transaction_id,
    t.amount,
    t.description
FROM Transactions t
WHERE ABS(t.amount) > (
    SELECT AVG(ABS(amount)) FROM Transactions
);


PRINT 'List of Users and Their Accounts';

SELECT 
    u.username,
    a.account_id,
    a.account_type,
    a.balance
FROM Users u
JOIN Account a ON u.user_id = a.user_id
ORDER BY u.username;


PRINT 'Transactions with Their Categories';

SELECT 
    t.transaction_id,
    t.amount,
    t.description,
    c.category_name
FROM Transactions t
JOIN Transaction_Category tc ON t.transaction_id = tc.transaction_id
JOIN Category c ON tc.category_id = c.category_id
ORDER BY t.transaction_date DESC;


PRINT 'Total Expenses per Category';

SELECT 
    c.category_name,
    SUM(e.amount) AS TotalExpenses
FROM Expense e
JOIN Budget b ON e.budget_id = b.budget_id
JOIN Category c ON b.category_id = c.category_id
GROUP BY c.category_name
ORDER BY TotalExpenses DESC;


PRINT 'Number of Notifications per User';

SELECT 
    u.username,
    COUNT(n.notification_id) AS NotificationCount
FROM Users u
LEFT JOIN Notification n ON u.user_id = n.user_id
GROUP BY u.username
ORDER BY NotificationCount DESC;


PRINT 'Users Who Have Exceeded Their Budgets';

SELECT 
    u.username,
    c.category_name,
    b.amount AS BudgetAmount,
    SUM(e.amount) AS TotalSpent
FROM Users u
JOIN Budget b ON u.user_id = b.user_id
JOIN Expense e ON b.budget_id = e.budget_id
JOIN Category c ON b.category_id = c.category_id
GROUP BY u.username, c.category_name, b.amount
HAVING SUM(e.amount) > b.amount;


PRINT 'Progress Towards Financial Goals per User';

SELECT 
    u.username,
    fg.target_amount,
    fg.current_progress,
    (fg.target_amount - fg.current_progress) AS remaining_amount,
    CASE 
        WHEN fg.current_progress >= fg.target_amount THEN 'Goal Achieved'
        ELSE 'In Progress'
    END AS progress_status
FROM Users u
JOIN Financial_Goal fg ON u.user_id = fg.user_id
ORDER BY u.username;