-- Library Management System - Database Creation Script
-- DBMS: MySQL 8.0+ (Compatible with PostgreSQL with minor modifications)

-- Drop existing database if exists (use with caution!)
DROP DATABASE IF EXISTS library_management;

-- Create database
CREATE DATABASE library_management;
USE library_management;

-- ============================================
-- Table 1: CATEGORY
-- ============================================
CREATE TABLE CATEGORY (
    Category_ID INT AUTO_INCREMENT PRIMARY KEY,
    Category_Name VARCHAR(50) NOT NULL UNIQUE,
    Description TEXT,
    
    CONSTRAINT chk_category_name CHECK (LENGTH(Category_Name) > 0)
);

-- ============================================
-- Table 2: AUTHOR
-- ============================================
CREATE TABLE AUTHOR (
    Author_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Biography TEXT,
    Country VARCHAR(50),
    
    CONSTRAINT chk_author_name CHECK (LENGTH(Name) > 0)
);

-- ============================================
-- Table 3: BOOK
-- ============================================
CREATE TABLE BOOK (
    ISBN VARCHAR(13) PRIMARY KEY,
    Title VARCHAR(200) NOT NULL,
    Publisher VARCHAR(100) NOT NULL,
    Publication_Year INT NOT NULL,
    Total_Copies INT NOT NULL,
    Available_Copies INT NOT NULL,
    Category_ID INT NOT NULL,
    
    -- Foreign Key Constraints
    CONSTRAINT fk_book_category 
        FOREIGN KEY (Category_ID) 
        REFERENCES CATEGORY(Category_ID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    -- Check Constraints
    CONSTRAINT chk_isbn_length CHECK (LENGTH(ISBN) = 13),
    CONSTRAINT chk_isbn_numeric CHECK (ISBN REGEXP '^[0-9]{13}$'),
    CONSTRAINT chk_publication_year CHECK (Publication_Year >= 1800 AND Publication_Year <= 2030),
    CONSTRAINT chk_total_copies CHECK (Total_Copies >= 1),
    CONSTRAINT chk_available_copies CHECK (Available_Copies >= 0),
    CONSTRAINT chk_copies_logic CHECK (Available_Copies <= Total_Copies),
    CONSTRAINT chk_title_not_empty CHECK (LENGTH(Title) > 0)
);

-- ============================================
-- Table 4: BOOK_AUTHOR (Junction Table)
-- ============================================
CREATE TABLE BOOK_AUTHOR (
    ISBN VARCHAR(13) NOT NULL,
    Author_ID INT NOT NULL,
    
    -- Composite Primary Key
    PRIMARY KEY (ISBN, Author_ID),
    
    -- Foreign Key Constraints
    CONSTRAINT fk_bookauthor_book 
        FOREIGN KEY (ISBN) 
        REFERENCES BOOK(ISBN)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_bookauthor_author 
        FOREIGN KEY (Author_ID) 
        REFERENCES AUTHOR(Author_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ============================================
-- Table 5: MEMBER
-- ============================================
CREATE TABLE MEMBER (
    Member_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(10) NOT NULL,
    Address VARCHAR(200),
    Join_Date DATE NOT NULL DEFAULT (CURRENT_DATE),
    Membership_Type ENUM('Student', 'Faculty', 'General') NOT NULL,
    Total_Fine DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    
    -- Check Constraints
    CONSTRAINT chk_member_name CHECK (LENGTH(Name) > 0),
    CONSTRAINT chk_member_email CHECK (Email LIKE '%@%.%'),
    CONSTRAINT chk_member_phone CHECK (Phone REGEXP '^[0-9]{10}$'),
    CONSTRAINT chk_total_fine CHECK (Total_Fine >= 0)
);

-- ============================================
-- Table 6: STAFF
-- ============================================
CREATE TABLE STAFF (
    Staff_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(10) NOT NULL,
    Role VARCHAR(50) NOT NULL,
    Hire_Date DATE NOT NULL,
    
    -- Check Constraints
    CONSTRAINT chk_staff_name CHECK (LENGTH(Name) > 0),
    CONSTRAINT chk_staff_email CHECK (Email LIKE '%@%.%'),
    CONSTRAINT chk_staff_phone CHECK (Phone REGEXP '^[0-9]{10}$')
);

-- ============================================
-- Table 7: LOAN
-- ============================================
CREATE TABLE LOAN (
    Loan_ID INT AUTO_INCREMENT PRIMARY KEY,
    ISBN VARCHAR(13) NOT NULL,
    Member_ID INT NOT NULL,
    Staff_ID INT NOT NULL,
    Issue_Date DATE NOT NULL DEFAULT (CURRENT_DATE),
    Due_Date DATE NOT NULL,
    Return_Date DATE,
    Fine_Amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    Status ENUM('Active', 'Returned', 'Overdue') NOT NULL DEFAULT 'Active',
    
    -- Foreign Key Constraints
    CONSTRAINT fk_loan_book 
        FOREIGN KEY (ISBN) 
        REFERENCES BOOK(ISBN)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_loan_member 
        FOREIGN KEY (Member_ID) 
        REFERENCES MEMBER(Member_ID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_loan_staff 
        FOREIGN KEY (Staff_ID) 
        REFERENCES STAFF(Staff_ID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    -- Check Constraints
    CONSTRAINT chk_due_date CHECK (Due_Date > Issue_Date),
    CONSTRAINT chk_return_date CHECK (Return_Date IS NULL OR Return_Date >= Issue_Date),
    CONSTRAINT chk_fine_amount CHECK (Fine_Amount >= 0 AND Fine_Amount <= 1000),
    
    -- Business Rule: Member cannot borrow same book twice simultaneously
    CONSTRAINT unique_active_loan UNIQUE (ISBN, Member_ID, Status)
);

-- ============================================
-- Create Indexes for Performance
-- ============================================

-- Indexes on Foreign Keys
CREATE INDEX idx_book_category ON BOOK(Category_ID);
CREATE INDEX idx_loan_isbn ON LOAN(ISBN);
CREATE INDEX idx_loan_member ON LOAN(Member_ID);
CREATE INDEX idx_loan_staff ON LOAN(Staff_ID);
CREATE INDEX idx_bookauthor_author ON BOOK_AUTHOR(Author_ID);

-- Indexes on Frequently Searched Columns
CREATE INDEX idx_book_title ON BOOK(Title);
CREATE INDEX idx_author_name ON AUTHOR(Name);
CREATE INDEX idx_member_email ON MEMBER(Email);
CREATE INDEX idx_loan_status ON LOAN(Status);
CREATE INDEX idx_loan_due_date ON LOAN(Due_Date);

-- Composite Indexes for Common Queries
CREATE INDEX idx_loan_member_status ON LOAN(Member_ID, Status);
CREATE INDEX idx_book_category_available ON BOOK(Category_ID, Available_Copies);

-- ============================================
-- Display Table Structure
-- ============================================
SHOW TABLES;

-- Display structure of each table
DESCRIBE CATEGORY;
DESCRIBE AUTHOR;
DESCRIBE BOOK;
DESCRIBE BOOK_AUTHOR;
DESCRIBE MEMBER;
DESCRIBE STAFF;
DESCRIBE LOAN;

-- Success message
SELECT 'Database and tables created successfully!' AS Status;
