# Library Management System - Relational Schema

## Relational Schema Notation

### CATEGORY
```
CATEGORY(Category_ID, Category_Name, Description)
  Primary Key: Category_ID
  Unique: Category_Name
```

---

### AUTHOR
```
AUTHOR(Author_ID, Name, Biography, Country)
  Primary Key: Author_ID
```

---

### BOOK
```
BOOK(ISBN, Title, Publisher, Publication_Year, Total_Copies, Available_Copies, Category_ID)
  Primary Key: ISBN
  Foreign Key: Category_ID REFERENCES CATEGORY(Category_ID)
  Check: Available_Copies <= Total_Copies
  Check: Available_Copies >= 0
  Check: Total_Copies >= 1
  Check: Publication_Year >= 1800
```

---

### BOOK_AUTHOR
```
BOOK_AUTHOR(ISBN, Author_ID)
  Primary Key: (ISBN, Author_ID)
  Foreign Key: ISBN REFERENCES BOOK(ISBN) ON DELETE CASCADE
  Foreign Key: Author_ID REFERENCES AUTHOR(Author_ID) ON DELETE CASCADE
```

---

### MEMBER
```
MEMBER(Member_ID, Name, Email, Phone, Address, Join_Date, Membership_Type, Total_Fine)
  Primary Key: Member_ID
  Unique: Email
  Check: Membership_Type IN ('Student', 'Faculty', 'General')
  Check: Total_Fine >= 0
```

---

### STAFF
```
STAFF(Staff_ID, Name, Email, Phone, Role, Hire_Date)
  Primary Key: Staff_ID
  Unique: Email
```

---

### LOAN
```
LOAN(Loan_ID, ISBN, Member_ID, Staff_ID, Issue_Date, Due_Date, Return_Date, Fine_Amount, Status)
  Primary Key: Loan_ID
  Foreign Key: ISBN REFERENCES BOOK(ISBN)
  Foreign Key: Member_ID REFERENCES MEMBER(Member_ID)
  Foreign Key: Staff_ID REFERENCES STAFF(Staff_ID)
  Check: Due_Date > Issue_Date
  Check: Return_Date >= Issue_Date (if Return_Date IS NOT NULL)
  Check: Fine_Amount >= 0
  Check: Fine_Amount <= 1000
  Check: Status IN ('Active', 'Returned', 'Overdue')
```

---

## Functional Dependencies

### BOOK
- ISBN → Title, Publisher, Publication_Year, Total_Copies, Available_Copies, Category_ID

### AUTHOR
- Author_ID → Name, Biography, Country

### CATEGORY
- Category_ID → Category_Name, Description
- Category_Name → Category_ID (candidate key)

### MEMBER
- Member_ID → Name, Email, Phone, Address, Join_Date, Membership_Type, Total_Fine
- Email → Member_ID (candidate key)

### STAFF
- Staff_ID → Name, Email, Phone, Role, Hire_Date
- Email → Staff_ID (candidate key)

### LOAN
- Loan_ID → ISBN, Member_ID, Staff_ID, Issue_Date, Due_Date, Return_Date, Fine_Amount, Status

### BOOK_AUTHOR
- No non-trivial functional dependencies (composite key)

---

## Normalization Analysis

### 1NF (First Normal Form)
✅ All tables are in 1NF:
- All attributes contain atomic values
- No repeating groups
- Each table has a primary key

### 2NF (Second Normal Form)
✅ All tables are in 2NF:
- All tables are in 1NF
- No partial dependencies (all non-key attributes depend on the entire primary key)
- BOOK_AUTHOR has composite key, but no non-key attributes

### 3NF (Third Normal Form)
✅ All tables are in 3NF:
- All tables are in 2NF
- No transitive dependencies
- All non-key attributes depend directly on the primary key

### BCNF (Boyce-Codd Normal Form)
✅ All tables are in BCNF:
- All tables are in 3NF
- For every functional dependency X → Y, X is a superkey

**Conclusion:** The schema is fully normalized to BCNF.

---

## Referential Integrity Actions

### ON DELETE Actions

#### BOOK_AUTHOR
- `ON DELETE CASCADE` for both foreign keys
- **Reason:** If a book or author is deleted, the association should also be removed

#### LOAN
- `ON DELETE RESTRICT` for ISBN
- **Reason:** Cannot delete a book that has loan records (maintain history)
- `ON DELETE RESTRICT` for Member_ID
- **Reason:** Cannot delete a member with loan history
- `ON DELETE RESTRICT` for Staff_ID
- **Reason:** Cannot delete staff with transaction history

#### BOOK
- `ON DELETE RESTRICT` for Category_ID
- **Reason:** Cannot delete a category that has books

### ON UPDATE Actions
- `ON UPDATE CASCADE` for all foreign keys
- **Reason:** If a primary key is updated, all references should be updated automatically

---

## Indexes for Performance

### Recommended Indexes

```sql
-- Primary keys (automatically indexed)
-- ISBN, Author_ID, Category_ID, Member_ID, Staff_ID, Loan_ID

-- Foreign keys (for join performance)
CREATE INDEX idx_book_category ON BOOK(Category_ID);
CREATE INDEX idx_loan_isbn ON LOAN(ISBN);
CREATE INDEX idx_loan_member ON LOAN(Member_ID);
CREATE INDEX idx_loan_staff ON LOAN(Staff_ID);
CREATE INDEX idx_bookauthor_author ON BOOK_AUTHOR(Author_ID);

-- Frequently searched columns
CREATE INDEX idx_book_title ON BOOK(Title);
CREATE INDEX idx_member_email ON MEMBER(Email);
CREATE INDEX idx_loan_status ON LOAN(Status);
CREATE INDEX idx_loan_due_date ON LOAN(Due_Date);

-- Composite indexes for common queries
CREATE INDEX idx_loan_member_status ON LOAN(Member_ID, Status);
CREATE INDEX idx_book_category_available ON BOOK(Category_ID, Available_Copies);
```

---

## Schema Diagram (Text Representation)

```
┌─────────────┐
│  CATEGORY   │
├─────────────┤
│ Category_ID │ PK
│ Category_Name│ UNIQUE
│ Description │
└─────────────┘
       ↑
       │ 1
       │
       │ N
┌─────────────────────┐         ┌──────────────┐
│       BOOK          │ M ───── N │    AUTHOR    │
├─────────────────────┤           ├──────────────┤
│ ISBN                │ PK        │ Author_ID    │ PK
│ Title               │           │ Name         │
│ Publisher           │           │ Biography    │
│ Publication_Year    │           │ Country      │
│ Total_Copies        │           └──────────────┘
│ Available_Copies    │                  │
│ Category_ID         │ FK               │
└─────────────────────┘                  │
       ↑ 1                               │
       │                                 │
       │                          ┌──────────────┐
       │ N                        │ BOOK_AUTHOR  │
┌─────────────────────┐           ├──────────────┤
│       LOAN          │           │ ISBN         │ PK, FK
├─────────────────────┤           │ Author_ID    │ PK, FK
│ Loan_ID             │ PK        └──────────────┘
│ ISBN                │ FK
│ Member_ID           │ FK
│ Staff_ID            │ FK
│ Issue_Date          │
│ Due_Date            │
│ Return_Date         │
│ Fine_Amount         │
│ Status              │
└─────────────────────┘
       ↑ N                 ↑ N
       │                   │
       │ 1                 │ 1
┌─────────────┐     ┌─────────────┐
│   MEMBER    │     │    STAFF    │
├─────────────┤     ├─────────────┤
│ Member_ID   │ PK  │ Staff_ID    │ PK
│ Name        │     │ Name        │
│ Email       │ UQ  │ Email       │ UQ
│ Phone       │     │ Phone       │
│ Address     │     │ Role        │
│ Join_Date   │     │ Hire_Date   │
│ Membership_ │     └─────────────┘
│   Type      │
│ Total_Fine  │
└─────────────┘
```

---

## Next Step
Proceed to SQL implementation (create_tables.sql)
