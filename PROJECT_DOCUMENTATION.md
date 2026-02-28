# Library Management System - Complete Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [System Architecture](#system-architecture)
3. [Database Design](#database-design)
4. [Application Flow](#application-flow)
5. [Setup Instructions](#setup-instructions)
6. [Features & Usage](#features--usage)

---

## 1. Project Overview

### Purpose
A web-based Library Management System to manage library operations including book inventory, member management, and book lending/returning processes with real-time database updates.

### Technology Stack
- **Frontend:** HTML5, Bootstrap 5, Jinja2 Templates
- **Backend:** Python Flask
- **Database:** MySQL 8.0+
- **Dependencies:** mysql-connector-python, Flask

### User Roles
1. **Librarian/Staff**: Manage books, members, and process loans
2. **Member**: Borrow and return books

---

## 2. System Architecture

### Application Structure
```
library-management-system/
├── python-frontend/
│   ├── app.py                    # Main Flask application
│   ├── requirements.txt          # Python dependencies
│   ├── test_connection.py        # Database connection tester
│   └── templates/
│       ├── base.html            # Base template with navigation
│       ├── index.html           # Dashboard/Homepage
│       ├── browse_books.html    # View all books
│       ├── issue_book.html      # Issue books to members
│       ├── return_book.html     # Return books
│       ├── view_loans.html      # View loan records
│       ├── add_book.html        # Add new books
│       ├── add_member.html      # Add new members
│       └── reports.html         # Statistics and reports
├── sql/
│   ├── create_tables.sql        # Database schema creation
│   └── insert_sample_data.sql   # Sample data insertion
└── Documentation files
```

### Database Connection
- Direct MySQL connection using `mysql-connector-python`
- Connection pooling for performance
- Automatic error handling and rollback

---

## 3. Database Design

### 3.1 Entities and Relationships

#### Entity Summary
1. **CATEGORY** - Book categories (Fiction, Science, etc.)
2. **AUTHOR** - Book authors
3. **BOOK** - Book inventory
4. **BOOK_AUTHOR** - Many-to-many relationship between books and authors
5. **MEMBER** - Library members
6. **STAFF** - Library staff
7. **LOAN** - Book loan transactions

### 3.2 Relational Schema

#### CATEGORY
```sql
CATEGORY(Category_ID, Category_Name, Description)
  Primary Key: Category_ID
  Unique: Category_Name
```

#### AUTHOR
```sql
AUTHOR(Author_ID, Name, Biography, Country)
  Primary Key: Author_ID
```

#### BOOK
```sql
BOOK(ISBN, Title, Publisher, Publication_Year, Total_Copies, Available_Copies, Category_ID)
  Primary Key: ISBN
  Foreign Key: Category_ID REFERENCES CATEGORY(Category_ID)
  Constraints:
    - Available_Copies <= Total_Copies
    - Available_Copies >= 0
    - Total_Copies >= 1
```

#### BOOK_AUTHOR (Junction Table)
```sql
BOOK_AUTHOR(ISBN, Author_ID)
  Primary Key: (ISBN, Author_ID)
  Foreign Key: ISBN REFERENCES BOOK(ISBN) ON DELETE CASCADE
  Foreign Key: Author_ID REFERENCES AUTHOR(Author_ID) ON DELETE CASCADE
```

#### MEMBER
```sql
MEMBER(Member_ID, Name, Email, Phone, Address, Join_Date, Membership_Type, Total_Fine)
  Primary Key: Member_ID
  Unique: Email
  Membership_Type: 'Student', 'Faculty', 'General'
  Constraint: Total_Fine >= 0
```

#### STAFF
```sql
STAFF(Staff_ID, Name, Email, Phone, Role, Hire_Date)
  Primary Key: Staff_ID
  Unique: Email
```

#### LOAN
```sql
LOAN(Loan_ID, ISBN, Member_ID, Staff_ID, Issue_Date, Due_Date, Return_Date, Fine_Amount, Status)
  Primary Key: Loan_ID
  Foreign Keys:
    - ISBN REFERENCES BOOK(ISBN)
    - Member_ID REFERENCES MEMBER(Member_ID)
    - Staff_ID REFERENCES STAFF(Staff_ID)
  Status: 'Active', 'Returned', 'Overdue'
  Constraints:
    - Due_Date > Issue_Date
    - Fine_Amount >= 0 AND <= 1000
```

### 3.3 ER Diagram (Text Representation)

```
┌─────────────┐
│  CATEGORY   │
├─────────────┤
│ Category_ID │ PK
│ Category_Name│ UNIQUE
│ Description │
└─────────────┘
       ↑
       │ 1:N
       │
┌─────────────────────┐         ┌──────────────┐
│       BOOK          │ M:N     │    AUTHOR    │
├─────────────────────┤ ─────── ├──────────────┤
│ ISBN                │ PK      │ Author_ID    │ PK
│ Title               │         │ Name         │
│ Publisher           │         │ Biography    │
│ Publication_Year    │         │ Country      │
│ Total_Copies        │         └──────────────┘
│ Available_Copies    │                │
│ Category_ID         │ FK             │
└─────────────────────┘                │
       ↑ 1:N                           │
       │                        ┌──────────────┐
       │                        │ BOOK_AUTHOR  │
       │ N:1                    ├──────────────┤
┌─────────────────────┐         │ ISBN         │ PK, FK
│       LOAN          │         │ Author_ID    │ PK, FK
├─────────────────────┤         └──────────────┘
│ Loan_ID             │ PK
│ ISBN                │ FK
│ Member_ID           │ FK
│ Staff_ID            │ FK
│ Issue_Date          │
│ Due_Date            │
│ Return_Date         │
│ Fine_Amount         │
│ Status              │
└─────────────────────┘
    ↑ N         ↑ N
    │ 1:N       │ 1:N
    │           │
┌─────────────┐ ┌─────────────┐
│   MEMBER    │ │    STAFF    │
├─────────────┤ ├─────────────┤
│ Member_ID   │ │ Staff_ID    │ PK
│ Name        │ │ Name        │
│ Email       │ │ Email       │ UNIQUE
│ Phone       │ │ Phone       │
│ Address     │ │ Role        │
│ Join_Date   │ │ Hire_Date   │
│ Membership_ │ └─────────────┘
│   Type      │
│ Total_Fine  │
└─────────────┘
```

### 3.4 Business Rules

#### Book Rules
- Each book has a unique ISBN (13 digits)
- A book can have multiple authors
- A book belongs to one category
- Library maintains multiple copies of the same book
- Books can only be borrowed if copies are available

#### Member Rules
- Each member has a unique Member ID
- Members can borrow maximum 3 books at a time
- **Membership Types & Loan Periods:**
  - **Student**: 14-day loan, ₹5/day fine
  - **Faculty**: 30-day loan, ₹3/day fine
  - **General**: 7-day loan, ₹10/day fine
- Members cannot borrow if they have overdue books or fines > ₹500

#### Loan Rules
- Due date calculated based on membership type
- Fine calculated from day after due date
- Maximum fine per book: ₹1000
- Status automatically updated based on dates

### 3.5 Normalization
The database schema is in **BCNF (Boyce-Codd Normal Form)**:
- ✅ 1NF: All attributes are atomic
- ✅ 2NF: No partial dependencies
- ✅ 3NF: No transitive dependencies
- ✅ BCNF: All determinants are candidate keys

---

## 4. Application Flow

### 4.1 System Workflow

```
┌─────────────────────────────────────────────────────────┐
│                    User Access                          │
│                  (Web Browser)                          │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│              Flask Application (app.py)                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Routes:                                        │   │
│  │  • /                    → Dashboard             │   │
│  │  • /browse              → View Books            │   │
│  │  • /issue               → Issue Book            │   │
│  │  • /return              → Return Book           │   │
│  │  • /loans               → View Loans            │   │
│  │  • /add_book            → Add New Book          │   │
│  │  • /add_member          → Add New Member        │   │
│  │  • /reports             → View Reports          │   │
│  └─────────────────────────────────────────────────┘   │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│         MySQL Database (library_management)             │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Tables: CATEGORY, AUTHOR, BOOK, BOOK_AUTHOR,  │   │
│  │          MEMBER, STAFF, LOAN                    │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### 4.2 Key Operations Flow

#### Issue Book Flow
```
1. User selects "Issue Book" from navigation
2. System displays form with:
   - Dropdown of available books (Available_Copies > 0)
   - Dropdown of active members
   - Dropdown of staff members
3. User submits form
4. System validates:
   - Book availability
   - Member eligibility (no overdue books, fines < ₹500)
5. System calculates due date based on membership type
6. System creates LOAN record with Status='Active'
7. System decrements Available_Copies in BOOK table
8. System displays success message
```

#### Return Book Flow
```
1. User selects "Return Book" from navigation
2. System displays all active loans
3. User clicks "Return" on a loan
4. System calculates fine (if overdue)
5. System updates LOAN record:
   - Sets Return_Date = today
   - Sets Fine_Amount (if applicable)
   - Sets Status = 'Returned'
6. System increments Available_Copies in BOOK table
7. System updates Member's Total_Fine
8. System displays success message with fine details
```

#### Add Book Flow
```
1. User selects "Add Book" from navigation
2. System displays form with:
   - Book details (ISBN, Title, Publisher, Year)
   - Category dropdown
   - Copy counts
3. User submits form
4. System validates ISBN uniqueness
5. System inserts into BOOK table
6. System displays success message
```

### 4.3 Database Transactions

All critical operations use transactions to ensure data consistency:

```python
# Example: Issue Book Transaction
try:
    cursor.execute("START TRANSACTION")
    
    # 1. Create loan record
    cursor.execute("INSERT INTO LOAN ...")
    
    # 2. Update book availability
    cursor.execute("UPDATE BOOK SET Available_Copies = Available_Copies - 1 ...")
    
    connection.commit()
except:
    connection.rollback()
    # Handle error
```

---

## 5. Setup Instructions

### 5.1 Prerequisites
- Python 3.8 or higher
- MySQL 8.0 or higher
- MySQL Workbench (optional, for database management)

### 5.2 Database Setup

**Step 1: Create Database and Tables**
```bash
# Open MySQL Workbench or MySQL CLI
# Run the script: sql/create_tables.sql
```

**Step 2: Insert Sample Data**
```bash
# Run the script: sql/insert_sample_data.sql
# This will populate the database with:
# - 8 categories
# - 10 authors
# - 30 books
# - 15 members
# - 5 staff
# - 20+ loan records
```

### 5.3 Application Setup

**Step 1: Install Python Dependencies**
```bash
cd python-frontend
pip install -r requirements.txt
```

**Step 2: Configure Database Connection**
Edit `app.py` and update the database configuration:
```python
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'your_password',  # Update this
    'database': 'library_management'
}
```

**Step 3: Test Database Connection**
```bash
python test_connection.py
```

**Step 4: Run the Application**
```bash
python app.py
```

**Step 5: Access the Application**
Open browser and navigate to: `http://localhost:5000`

---

## 6. Features & Usage

### 6.1 Dashboard (Homepage)
- **URL:** `/`
- **Features:**
  - Quick statistics (total books, members, active loans)
  - Recent activity
  - Quick action buttons

### 6.2 Browse Books
- **URL:** `/browse`
- **Features:**
  - View all books with details
  - See availability status
  - Filter by category
  - Search by title or ISBN

### 6.3 Issue Book
- **URL:** `/issue`
- **Features:**
  - Select book from available inventory
  - Select member
  - Select staff member processing the transaction
  - Automatic due date calculation
  - Real-time validation

### 6.4 Return Book
- **URL:** `/return`
- **Features:**
  - View all active loans
  - One-click return
  - Automatic fine calculation
  - Updates member's fine balance
  - Updates book availability

### 6.5 View Loans
- **URL:** `/loans`
- **Features:**
  - View all loan records
  - Filter by status (Active, Returned, Overdue)
  - See loan details (dates, fines, status)
  - Member and book information

### 6.6 Add Book
- **URL:** `/add_book`
- **Features:**
  - Add new books to inventory
  - Assign category
  - Set copy counts
  - ISBN validation

### 6.7 Add Member
- **URL:** `/add_member`
- **Features:**
  - Register new members
  - Select membership type
  - Email validation
  - Automatic join date

### 6.8 Reports
- **URL:** `/reports`
- **Features:**
  - Total books by category
  - Most borrowed books
  - Member statistics
  - Overdue books list
  - Fine collection summary

---

## 7. Database Maintenance

### 7.1 Resetting Sample Data
To reset the database with fresh sample data:
```bash
# Run: sql/insert_sample_data.sql
# This script automatically:
# 1. Clears all existing data
# 2. Resets auto-increment counters
# 3. Inserts fresh sample data
```

### 7.2 Backup Database
```sql
-- Export database
mysqldump -u root -p library_management > backup.sql

-- Import database
mysql -u root -p library_management < backup.sql
```

### 7.3 Common Queries

**Check overdue books:**
```sql
SELECT l.Loan_ID, b.Title, m.Name, l.Due_Date
FROM LOAN l
JOIN BOOK b ON l.ISBN = b.ISBN
JOIN MEMBER m ON l.Member_ID = m.Member_ID
WHERE l.Status = 'Overdue';
```

**View member borrowing history:**
```sql
SELECT m.Name, b.Title, l.Issue_Date, l.Return_Date, l.Status
FROM LOAN l
JOIN MEMBER m ON l.Member_ID = m.Member_ID
JOIN BOOK b ON l.ISBN = b.ISBN
WHERE m.Member_ID = 1
ORDER BY l.Issue_Date DESC;
```

**Books by category:**
```sql
SELECT c.Category_Name, COUNT(*) as Book_Count
FROM BOOK b
JOIN CATEGORY c ON b.Category_ID = c.Category_ID
GROUP BY c.Category_Name;
```

---

## 8. Troubleshooting

### Common Issues

**Issue: Cannot connect to database**
- Verify MySQL is running
- Check credentials in `app.py`
- Ensure database `library_management` exists

**Issue: Duplicate entry errors**
- Run `insert_sample_data.sql` which clears existing data first
- Check for unique constraint violations (ISBN, Email)

**Issue: Foreign key constraint fails**
- Ensure referenced records exist
- Check referential integrity
- Verify data insertion order

**Issue: Application won't start**
- Check Python version (3.8+)
- Verify all dependencies installed: `pip install -r requirements.txt`
- Check port 5000 is not in use

---

## 9. Future Enhancements

### Potential Features
1. **User Authentication:** Login system for staff and members
2. **Book Reservations:** Allow members to reserve borrowed books
3. **Email Notifications:** Overdue reminders and due date alerts
4. **Advanced Search:** Full-text search, filters, sorting
5. **Book Reviews:** Member ratings and reviews
6. **Fine Payment:** Online payment integration
7. **Reports Export:** PDF/Excel export functionality
8. **Mobile App:** Responsive design or native mobile app

---

## 10. Project Summary

This Library Management System provides a complete solution for managing library operations with:
- ✅ Robust database design (BCNF normalized)
- ✅ Real-time inventory tracking
- ✅ Automatic fine calculation
- ✅ User-friendly web interface
- ✅ Transaction safety with ACID properties
- ✅ Comprehensive reporting
- ✅ Sample data for testing

The system demonstrates proper database design principles, referential integrity, and practical implementation of a multi-table relational database with a modern web interface.

---

**Last Updated:** February 2026
**Version:** 1.0
**Author:** Library Management System Team
