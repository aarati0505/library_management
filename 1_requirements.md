# Library Management System - Requirements & Assumptions

## System Overview
A database-backed system to manage library operations including book inventory, member management, and book lending/returning processes.

## User Roles
1. **Librarian/Staff**: Can manage books, members, and process loans
2. **Member**: Can borrow and return books

## Core Features

### 1. Book Management
- Add new books to the library
- Update book information
- Remove books from inventory
- Track available vs borrowed copies
- Categorize books by genre/category
- Link books with authors

### 2. Member Management
- Register new members
- Update member information
- Track membership type (Student, Faculty, General)
- View member borrowing history
- Calculate and track fines

### 3. Loan Management
- Issue books to members
- Record return of books
- Calculate due dates
- Track overdue books
- Calculate fines for late returns
- Prevent borrowing if member has overdue books or unpaid fines

### 4. Search & Reports
- Search books by title, author, ISBN, or category
- View available books
- View member loan history
- Generate reports on most borrowed books
- List overdue books and fines

## Business Rules & Assumptions

### Book Rules
1. Each book has a unique ISBN
2. A book can have multiple authors (co-authors)
3. A book belongs to one category
4. Library maintains multiple copies of the same book
5. A book can only be borrowed if copies are available

### Member Rules
1. Each member has a unique Member ID
2. Members can borrow maximum 3 books at a time
3. Membership types:
   - **Student**: 14-day loan period, ₹5/day fine
   - **Faculty**: 30-day loan period, ₹3/day fine
   - **General**: 7-day loan period, ₹10/day fine
4. Members cannot borrow new books if they have:
   - Overdue books
   - Unpaid fines exceeding ₹500

### Loan Rules
1. Each loan has a unique Loan ID
2. Due date is calculated based on membership type
3. Fine is calculated from the day after due date
4. Maximum fine per book is capped at ₹1000
5. Books can be renewed once if no one else has reserved it
6. A member can reserve a book if all copies are currently borrowed

### Staff Rules
1. Only staff can issue and accept returns
2. Staff records are maintained for audit purposes
3. Each transaction is linked to the staff member who processed it

## System Constraints

### Domain Constraints
- ISBN: 13-digit number
- Email: Valid email format
- Phone: 10-digit number
- Fine Amount: Non-negative decimal
- Available Copies: Cannot be negative
- Available Copies ≤ Total Copies

### Key Constraints
- ISBN is unique for each book
- Member_ID is unique for each member
- Loan_ID is unique for each loan transaction
- Staff_ID is unique for each staff member

### Entity Integrity
- All primary keys must be NOT NULL
- All primary keys must be unique

### Referential Integrity
- Every loan must reference a valid book (ISBN)
- Every loan must reference a valid member (Member_ID)
- Every loan must reference a valid staff member (Staff_ID)
- Every book must reference a valid category
- Book_Author must reference valid books and authors

### Semantic Constraints
- Return_Date must be >= Issue_Date (if not NULL)
- Due_Date must be > Issue_Date
- Available_Copies must be <= Total_Copies
- Available_Copies must be >= 0
- Member cannot borrow same book twice simultaneously
- Fine_Amount is calculated as: (Return_Date - Due_Date) × Daily_Fine_Rate

## Sample Data Requirements
- At least 30 books across 5-6 categories
- At least 15 members (mix of Student, Faculty, General)
- At least 5 authors
- At least 20 loan records (mix of active, returned, overdue)
- At least 3 staff members

## Non-Functional Requirements
- System should respond to queries within 2 seconds
- Database should maintain data consistency
- All transactions should follow ACID properties
- System should handle concurrent access (multiple staff members)
