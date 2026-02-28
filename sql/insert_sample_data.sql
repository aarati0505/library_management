-- Library Management System - Sample Data Insertion Script
USE library_management;

-- ============================================
-- Clear Existing Data (in correct order due to foreign keys)
-- ============================================
SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;

DELETE FROM LOAN;
DELETE FROM BOOK_AUTHOR;
DELETE FROM BOOK;
DELETE FROM MEMBER;
DELETE FROM STAFF;
DELETE FROM AUTHOR;
DELETE FROM CATEGORY;

-- Reset auto-increment counters
ALTER TABLE LOAN AUTO_INCREMENT = 1;
ALTER TABLE MEMBER AUTO_INCREMENT = 1;
ALTER TABLE STAFF AUTO_INCREMENT = 1;
ALTER TABLE AUTHOR AUTO_INCREMENT = 1;
ALTER TABLE CATEGORY AUTO_INCREMENT = 1;

SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES = 1;

-- ============================================
-- Insert Categories
-- ============================================
INSERT INTO CATEGORY (Category_Name, Description) VALUES
('Fiction', 'Fictional novels and stories'),
('Non-Fiction', 'Real-life events, biographies, and factual content'),
('Science', 'Scientific books covering physics, chemistry, biology'),
('Technology', 'Computer science, programming, and IT books'),
('History', 'Historical events and civilizations'),
('Biography', 'Life stories of notable personalities'),
('Self-Help', 'Personal development and motivational books'),
('Business', 'Management, economics, and entrepreneurship');

-- ============================================
-- Insert Authors
-- ============================================
INSERT INTO AUTHOR (Name, Biography, Country) VALUES
('J.K. Rowling', 'British author best known for Harry Potter series', 'United Kingdom'),
('George Orwell', 'English novelist and essayist', 'United Kingdom'),
('Yuval Noah Harari', 'Israeli historian and author', 'Israel'),
('Stephen Hawking', 'Theoretical physicist and cosmologist', 'United Kingdom'),
('Dale Carnegie', 'American writer and lecturer', 'United States'),
('Robert Kiyosaki', 'American businessman and author', 'United States'),
('Abdul Kalam', 'Indian scientist and former President', 'India'),
('Chetan Bhagat', 'Indian author and columnist', 'India'),
('Ruskin Bond', 'Indian author of British descent', 'India'),
('Agatha Christie', 'English writer known for detective novels', 'United Kingdom');

-- ============================================
-- Insert Books
-- ============================================
INSERT INTO BOOK (ISBN, Title, Publisher, Publication_Year, Total_Copies, Available_Copies, Category_ID) VALUES
('9780439708180', 'Harry Potter and the Sorcerer''s Stone', 'Scholastic', 1998, 5, 3, 1),
('9780451524935', '1984', 'Signet Classic', 1949, 4, 2, 1),
('9780062316097', 'Sapiens: A Brief History of Humankind', 'Harper', 2015, 6, 4, 2),
('9780553380163', 'A Brief History of Time', 'Bantam', 1988, 3, 1, 3),
('9780671027032', 'How to Win Friends and Influence People', 'Simon & Schuster', 1936, 5, 5, 7),
('9781612680194', 'Rich Dad Poor Dad', 'Plata Publishing', 1997, 4, 2, 8),
('9788173711466', 'Wings of Fire', 'Universities Press', 1999, 5, 3, 6),
('9788129135728', 'Five Point Someone', 'Rupa Publications', 2004, 6, 4, 1),
('9780143333623', 'The Room on the Roof', 'Penguin India', 1956, 3, 2, 1),
('9780062073488', 'Murder on the Orient Express', 'William Morrow', 1934, 4, 3, 1),
('9780062316110', 'Homo Deus: A Brief History of Tomorrow', 'Harper', 2017, 4, 4, 2),
('9780439139595', 'Harry Potter and the Goblet of Fire', 'Scholastic', 2000, 5, 2, 1),
('9780141036144', 'Animal Farm', 'Penguin Books', 1945, 4, 3, 1),
('9780143442295', 'The Blue Umbrella', 'Penguin India', 1980, 3, 3, 1),
('9788129137562', '2 States', 'Rupa Publications', 2009, 5, 3, 1),
('9780062315007', 'The Alchemist', 'HarperOne', 1988, 6, 4, 1),
('9780735619678', 'Steve Jobs', 'Simon & Schuster', 2011, 3, 2, 6),
('9780307887894', 'The Lean Startup', 'Crown Business', 2011, 4, 4, 8),
('9780062457714', 'The Subtle Art of Not Giving a F*ck', 'HarperOne', 2016, 5, 3, 7),
('9780143124542', 'Educated', 'Random House', 2018, 4, 2, 6),
('9780062316103', '21 Lessons for the 21st Century', 'Spiegel & Grau', 2018, 4, 3, 2),
('9780143419938', 'India After Gandhi', 'Picador', 2007, 3, 2, 5),
('9780143424277', 'The Discovery of India', 'Penguin India', 1946, 3, 3, 5),
('9780143440208', 'Train to Pakistan', 'Penguin India', 1956, 3, 2, 1),
('9788129137319', 'Revolution 2020', 'Rupa Publications', 2011, 4, 3, 1),
('9780143419662', 'The White Tiger', 'Atlantic Books', 2008, 4, 2, 1),
('9780062315008', 'The Monk Who Sold His Ferrari', 'HarperOne', 1997, 5, 4, 7),
('9780143442509', 'The God of Small Things', 'Penguin India', 1997, 3, 2, 1),
('9780143424321', 'Midnight''s Children', 'Penguin India', 1981, 3, 3, 1),
('9780374275631', 'Thinking, Fast and Slow', 'Farrar, Straus and Giroux', 2011, 4, 3, 2);

-- ============================================
-- Insert Book-Author Relationships
-- ============================================
INSERT INTO BOOK_AUTHOR (ISBN, Author_ID) VALUES
('9780439708180', 1),  -- Harry Potter 1 - J.K. Rowling
('9780451524935', 2),  -- 1984 - George Orwell
('9780062316097', 3),  -- Sapiens - Yuval Noah Harari
('9780553380163', 4),  -- A Brief History of Time - Stephen Hawking
('9780671027032', 5),  -- How to Win Friends - Dale Carnegie
('9781612680194', 6),  -- Rich Dad Poor Dad - Robert Kiyosaki
('9788173711466', 7),  -- Wings of Fire - Abdul Kalam
('9788129135728', 8),  -- Five Point Someone - Chetan Bhagat
('9780143333623', 9),  -- The Room on the Roof - Ruskin Bond
('9780062073488', 10), -- Murder on the Orient Express - Agatha Christie
('9780062316110', 3),  -- Homo Deus - Yuval Noah Harari
('9780439139595', 1),  -- Harry Potter 4 - J.K. Rowling
('9780141036144', 2),  -- Animal Farm - George Orwell
('9780143442295', 9),  -- The Blue Umbrella - Ruskin Bond
('9788129137562', 8),  -- 2 States - Chetan Bhagat
('9780062315007', 1),  -- The Alchemist - Paulo Coelho (using ID 1 as placeholder)
('9780735619678', 4),  -- Steve Jobs - Walter Isaacson (using ID 4 as placeholder)
('9780307887894', 6),  -- The Lean Startup - Eric Ries (using ID 6 as placeholder)
('9780062457714', 5),  -- The Subtle Art - Mark Manson (using ID 5 as placeholder)
('9780143124542', 7),  -- Educated - Tara Westover (using ID 7 as placeholder)
('9780143419938', 3),  -- India After Gandhi - Ramachandra Guha (using ID 3)
('9780143424277', 7),  -- The Discovery of India - Jawaharlal Nehru (using ID 7)
('9780143440208', 9),  -- Train to Pakistan - Khushwant Singh (using ID 9)
('9788129137319', 8),  -- Revolution 2020 - Chetan Bhagat
('9780143419662', 8),  -- The White Tiger - Aravind Adiga (using ID 8)
('9780062315008', 5),  -- The Monk Who Sold His Ferrari - Robin Sharma (using ID 5)
('9780143442509', 9),  -- The God of Small Things - Arundhati Roy (using ID 9)
('9780143424321', 9),  -- Midnight's Children - Salman Rushdie (using ID 9)
('9780374275631', 3);  -- Thinking Fast and Slow - Daniel Kahneman (using ID 3)

-- ============================================
-- Insert Staff Members
-- ============================================
INSERT INTO STAFF (Name, Email, Phone, Role, Hire_Date) VALUES
('Rajesh Kumar', 'rajesh.kumar@library.com', '9876543210', 'Head Librarian', '2020-01-15'),
('Priya Sharma', 'priya.sharma@library.com', '9876543211', 'Assistant Librarian', '2021-03-20'),
('Amit Patel', 'amit.patel@library.com', '9876543212', 'Librarian', '2021-06-10'),
('Sneha Reddy', 'sneha.reddy@library.com', '9876543213', 'Assistant Librarian', '2022-02-01'),
('Vikram Singh', 'vikram.singh@library.com', '9876543214', 'Librarian', '2022-08-15');

-- ============================================
-- Insert Members
-- ============================================
INSERT INTO MEMBER (Name, Email, Phone, Address, Join_Date, Membership_Type, Total_Fine) VALUES
('Rahul Verma', 'rahul.verma@email.com', '9123456780', '123 MG Road, Bangalore', '2023-01-10', 'Student', 0.00),
('Anita Desai', 'anita.desai@email.com', '9123456781', '456 Park Street, Kolkata', '2023-02-15', 'Faculty', 0.00),
('Karan Mehta', 'karan.mehta@email.com', '9123456782', '789 Marine Drive, Mumbai', '2023-03-20', 'General', 50.00),
('Pooja Iyer', 'pooja.iyer@email.com', '9123456783', '321 Anna Salai, Chennai', '2023-04-05', 'Student', 0.00),
('Sanjay Gupta', 'sanjay.gupta@email.com', '9123456784', '654 Connaught Place, Delhi', '2023-05-12', 'Faculty', 0.00),
('Neha Kapoor', 'neha.kapoor@email.com', '9123456785', '987 Brigade Road, Bangalore', '2023-06-18', 'Student', 25.00),
('Arjun Nair', 'arjun.nair@email.com', '9123456786', '147 MG Road, Kochi', '2023-07-22', 'General', 0.00),
('Divya Menon', 'divya.menon@email.com', '9123456787', '258 Residency Road, Bangalore', '2023-08-30', 'Student', 0.00),
('Rohan Joshi', 'rohan.joshi@email.com', '9123456788', '369 FC Road, Pune', '2023-09-14', 'Faculty', 0.00),
('Kavita Rao', 'kavita.rao@email.com', '9123456789', '741 Jubilee Hills, Hyderabad', '2023-10-20', 'Student', 0.00),
('Manish Agarwal', 'manish.agarwal@email.com', '9123456790', '852 Park Street, Kolkata', '2023-11-05', 'General', 100.00),
('Shreya Bose', 'shreya.bose@email.com', '9123456791', '963 Salt Lake, Kolkata', '2023-12-10', 'Student', 0.00),
('Aditya Malhotra', 'aditya.malhotra@email.com', '9123456792', '159 Sector 17, Chandigarh', '2024-01-15', 'Faculty', 0.00),
('Ritu Singh', 'ritu.singh@email.com', '9123456793', '357 Hazratganj, Lucknow', '2024-02-20', 'Student', 15.00),
('Varun Khanna', 'varun.khanna@email.com', '9123456794', '486 Civil Lines, Jaipur', '2024-03-25', 'General', 0.00);

-- ============================================
-- Insert Loan Records
-- ============================================

-- Active Loans (books currently borrowed)
INSERT INTO LOAN (ISBN, Member_ID, Staff_ID, Issue_Date, Due_Date, Return_Date, Fine_Amount, Status) VALUES
('9780439708180', 1, 1, '2024-02-15', '2024-03-01', NULL, 0.00, 'Active'),
('9780451524935', 4, 2, '2024-02-18', '2024-03-04', NULL, 0.00, 'Active'),
('9780553380163', 6, 3, '2024-02-20', '2024-03-06', NULL, 0.00, 'Active'),
('9780439139595', 8, 1, '2024-02-22', '2024-03-08', NULL, 0.00, 'Active'),
('9788129135728', 10, 2, '2024-02-25', '2024-03-11', NULL, 0.00, 'Active');

-- Overdue Loans (not returned past due date)
INSERT INTO LOAN (ISBN, Member_ID, Staff_ID, Issue_Date, Due_Date, Return_Date, Fine_Amount, Status) VALUES
('9781612680194', 3, 1, '2024-01-10', '2024-01-17', NULL, 50.00, 'Overdue'),
('9780143419662', 11, 3, '2024-01-15', '2024-01-22', NULL, 100.00, 'Overdue'),
('9788129137562', 6, 2, '2024-02-01', '2024-02-15', NULL, 25.00, 'Overdue'),
('9780143124542', 14, 1, '2024-02-05', '2024-02-19', NULL, 15.00, 'Overdue');

-- Returned Loans (completed transactions)
INSERT INTO LOAN (ISBN, Member_ID, Staff_ID, Issue_Date, Due_Date, Return_Date, Fine_Amount, Status) VALUES
('9780062316097', 1, 1, '2024-01-05', '2024-01-19', '2024-01-18', 0.00, 'Returned'),
('9780671027032', 2, 2, '2024-01-08', '2024-02-07', '2024-02-05', 0.00, 'Returned'),
('9788173711466', 4, 3, '2024-01-12', '2024-01-26', '2024-01-25', 0.00, 'Returned'),
('9780143333623', 5, 1, '2024-01-15', '2024-02-14', '2024-02-10', 0.00, 'Returned'),
('9780062073488', 7, 2, '2024-01-20', '2024-01-27', '2024-01-30', 30.00, 'Returned'),
('9780062316110', 9, 3, '2024-01-25', '2024-02-24', '2024-02-20', 0.00, 'Returned'),
('9780141036144', 12, 1, '2024-02-01', '2024-02-15', '2024-02-14', 0.00, 'Returned'),
('9780143442295', 13, 2, '2024-02-05', '2024-03-06', '2024-03-05', 0.00, 'Returned'),
('9780062315007', 15, 3, '2024-02-08', '2024-02-15', '2024-02-20', 50.00, 'Returned'),
('9780735619678', 2, 1, '2024-02-10', '2024-03-11', '2024-03-10', 0.00, 'Returned'),
('9780307887894', 5, 2, '2024-02-12', '2024-03-13', '2024-03-12', 0.00, 'Returned');

-- ============================================
-- Verify Data Insertion
-- ============================================
SELECT 'Data insertion completed!' AS Status;

-- Display counts
SELECT 'Categories' AS Table_Name, COUNT(*) AS Record_Count FROM CATEGORY
UNION ALL
SELECT 'Authors', COUNT(*) FROM AUTHOR
UNION ALL
SELECT 'Books', COUNT(*) FROM BOOK
UNION ALL
SELECT 'Book-Author Relations', COUNT(*) FROM BOOK_AUTHOR
UNION ALL
SELECT 'Members', COUNT(*) FROM MEMBER
UNION ALL
SELECT 'Staff', COUNT(*) FROM STAFF
UNION ALL
SELECT 'Loans', COUNT(*) FROM LOAN;
