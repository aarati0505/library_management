# Library Management System - Entities & Relationships

## Entities and Attributes

### 1. BOOK
**Primary Key:** ISBN

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| ISBN | VARCHAR(13) | PRIMARY KEY, NOT NULL | Unique book identifier |
| Title | VARCHAR(200) | NOT NULL | Book title |
| Publisher | VARCHAR(100) | NOT NULL | Publishing company |
| Publication_Year | INT | CHECK (>= 1800) | Year of publication |
| Total_Copies | INT | NOT NULL, CHECK (>= 1) | Total copies owned |
| Available_Copies | INT | NOT NULL, CHECK (>= 0) | Currently available copies |
| Category_ID | INT | FOREIGN KEY, NOT NULL | References Category |

**Constraints:**
- Available_Copies <= Total_Copies
- ISBN must be exactly 13 digits

---

### 2. AUTHOR
**Primary Key:** Author_ID

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| Author_ID | INT | PRIMARY KEY, AUTO_INCREMENT | Unique author identifier |
| Name | VARCHAR(100) | NOT NULL | Author's full name |
| Biography | TEXT | NULL | Brief biography |
| Country | VARCHAR(50) | NULL | Author's country |

---

### 3. CATEGORY
**Primary Key:** Category_ID

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| Category_ID | INT | PRIMARY KEY, AUTO_INCREMENT | Unique category identifier |
| Category_Name | VARCHAR(50) | NOT NULL, UNIQUE | Category name |
| Description | TEXT | NULL | Category description |

**Examples:** Fiction, Non-Fiction, Science, History, Biography, Technology, etc.

---

### 4. MEMBER
**Primary Key:** Member_ID

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| Member_ID | INT | PRIMARY KEY, AUTO_INCREMENT | Unique member identifier |
| Name | VARCHAR(100) | NOT NULL | Member's full name |
| Email | VARCHAR(100) | NOT NULL, UNIQUE | Email address |
| Phone | VARCHAR(10) | NOT NULL | Contact number |
| Address | VARCHAR(200) | NULL | Residential address |
| Join_Date | DATE | NOT NULL, DEFAULT CURRENT_DATE | Membership start date |
| Membership_Type | ENUM | NOT NULL | 'Student', 'Faculty', 'General' |
| Total_Fine | DECIMAL(10,2) | DEFAULT 0, CHECK (>= 0) | Accumulated unpaid fines |

---

### 5. STAFF
**Primary Key:** Staff_ID

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| Staff_ID | INT | PRIMARY KEY, AUTO_INCREMENT | Unique staff identifier |
| Name | VARCHAR(100) | NOT NULL | Staff member's name |
| Email | VARCHAR(100) | NOT NULL, UNIQUE | Email address |
| Phone | VARCHAR(10) | NOT NULL | Contact number |
| Role | VARCHAR(50) | NOT NULL | Job role (Librarian, Assistant) |
| Hire_Date | DATE | NOT NULL | Date of joining |

---

### 6. LOAN
**Primary Key:** Loan_ID

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| Loan_ID | INT | PRIMARY KEY, AUTO_INCREMENT | Unique loan identifier |
| ISBN | VARCHAR(13) | FOREIGN KEY, NOT NULL | References Book |
| Member_ID | INT | FOREIGN KEY, NOT NULL | References Member |
| Staff_ID | INT | FOREIGN KEY, NOT NULL | Staff who issued the book |
| Issue_Date | DATE | NOT NULL, DEFAULT CURRENT_DATE | Date book was issued |
| Due_Date | DATE | NOT NULL | Expected return date |
| Return_Date | DATE | NULL | Actual return date (NULL if not returned) |
| Fine_Amount | DECIMAL(10,2) | DEFAULT 0, CHECK (>= 0) | Fine for late return |
| Status | ENUM | NOT NULL | 'Active', 'Returned', 'Overdue' |

**Constraints:**
- Due_Date > Issue_Date
- Return_Date >= Issue_Date (if not NULL)
- Fine_Amount <= 1000 (maximum fine cap)

---

### 7. BOOK_AUTHOR (Junction Table for Many-to-Many)
**Primary Key:** (ISBN, Author_ID)

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| ISBN | VARCHAR(13) | FOREIGN KEY, NOT NULL | References Book |
| Author_ID | INT | FOREIGN KEY, NOT NULL | References Author |

---

## Relationships

### 1. Book ↔ Author (Many-to-Many)
- **Relationship:** WRITTEN_BY
- **Cardinality:** M:N
- **Participation:** 
  - Book: Total (every book must have at least one author)
  - Author: Partial (an author may not have books in this library)
- **Implementation:** Junction table BOOK_AUTHOR

---

### 2. Book ↔ Category (Many-to-One)
- **Relationship:** BELONGS_TO
- **Cardinality:** N:1
- **Participation:**
  - Book: Total (every book must belong to a category)
  - Category: Partial (a category may have no books)
- **Implementation:** Category_ID as foreign key in Book table

---

### 3. Book ↔ Loan (One-to-Many)
- **Relationship:** BORROWED_IN
- **Cardinality:** 1:N
- **Participation:**
  - Book: Partial (a book may never be borrowed)
  - Loan: Total (every loan must reference a book)
- **Implementation:** ISBN as foreign key in Loan table

---

### 4. Member ↔ Loan (One-to-Many)
- **Relationship:** BORROWS
- **Cardinality:** 1:N
- **Participation:**
  - Member: Partial (a member may never borrow books)
  - Loan: Total (every loan must reference a member)
- **Implementation:** Member_ID as foreign key in Loan table

---

### 5. Staff ↔ Loan (One-to-Many)
- **Relationship:** ISSUES
- **Cardinality:** 1:N
- **Participation:**
  - Staff: Partial (a staff member may not have issued any books yet)
  - Loan: Total (every loan must be issued by a staff member)
- **Implementation:** Staff_ID as foreign key in Loan table

---

## ER Diagram Notes

### Weak Entities
- None in this design (all entities have independent existence)

### Derived Attributes
- **Status** in Loan: Can be derived from Return_Date and Due_Date
  - If Return_Date is NULL and Due_Date < CURRENT_DATE → 'Overdue'
  - If Return_Date is NULL and Due_Date >= CURRENT_DATE → 'Active'
  - If Return_Date is NOT NULL → 'Returned'

### Multi-valued Attributes
- None (handled through relationships)

### Composite Attributes
- Address could be broken down into Street, City, State, Pincode (optional enhancement)

---

## Cardinality Summary

```
BOOK (1) ----< BELONGS_TO >---- (N) CATEGORY
BOOK (M) ----< WRITTEN_BY >---- (N) AUTHOR  [via BOOK_AUTHOR]
BOOK (1) ----< BORROWED_IN >---- (N) LOAN
MEMBER (1) ----< BORROWS >---- (N) LOAN
STAFF (1) ----< ISSUES >---- (N) LOAN
```

---

## Next Steps
1. Draw the ER diagram using these specifications
2. Convert to relational schema
3. Implement in SQL
