-- Library Management System - Clear All Data Script
-- WARNING: This will delete ALL data from all tables!
-- Use with caution - this action cannot be undone!

USE library_management;

-- ============================================
-- Disable safety checks temporarily
-- ============================================
SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- Delete all data from tables (in correct order)
-- ============================================

-- Delete loan records first (has foreign keys to multiple tables)
DELETE FROM LOAN;

-- Delete book-author relationships
DELETE FROM BOOK_AUTHOR;

-- Delete books
DELETE FROM BOOK;

-- Delete members
DELETE FROM MEMBER;

-- Delete staff
DELETE FROM STAFF;

-- Delete authors
DELETE FROM AUTHOR;

-- Delete categories
DELETE FROM CATEGORY;

-- ============================================
-- Reset auto-increment counters to 1
-- ============================================
ALTER TABLE LOAN AUTO_INCREMENT = 1;
ALTER TABLE MEMBER AUTO_INCREMENT = 1;
ALTER TABLE STAFF AUTO_INCREMENT = 1;
ALTER TABLE AUTHOR AUTO_INCREMENT = 1;
ALTER TABLE CATEGORY AUTO_INCREMENT = 1;

-- ============================================
-- Re-enable safety checks
-- ============================================
SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES = 1;

-- ============================================
-- Verify all tables are empty
-- ============================================
SELECT 'Data cleared successfully!' AS Status;

SELECT 'CATEGORY' AS Table_Name, COUNT(*) AS Record_Count FROM CATEGORY
UNION ALL
SELECT 'AUTHOR', COUNT(*) FROM AUTHOR
UNION ALL
SELECT 'BOOK', COUNT(*) FROM BOOK
UNION ALL
SELECT 'BOOK_AUTHOR', COUNT(*) FROM BOOK_AUTHOR
UNION ALL
SELECT 'MEMBER', COUNT(*) FROM MEMBER
UNION ALL
SELECT 'STAFF', COUNT(*) FROM STAFF
UNION ALL
SELECT 'LOAN', COUNT(*) FROM LOAN;

-- All counts should show 0
