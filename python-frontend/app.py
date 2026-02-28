"""
Library Management System - Python Flask Application
Simple frontend with direct MySQL connectivity
"""

from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
import mysql.connector
from datetime import datetime, timedelta
from decimal import Decimal

app = Flask(__name__)
app.secret_key = 'your-secret-key-here'  # Change this in production

# Database configuration
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'root',  # Change to your MySQL password (try: 'root', '', 'password', or your custom password)
    'database': 'library_management'
}

# Helper function to get database connection
def get_db_connection():
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except mysql.connector.Error as err:
        print(f"Error: {err}")
        return None

# Helper function to execute queries
def execute_query(query, params=None, fetch_one=False, fetch_all=False):
    conn = get_db_connection()
    if not conn:
        return None
    
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(query, params or ())
        
        if fetch_one:
            result = cursor.fetchone()
        elif fetch_all:
            result = cursor.fetchall()
        else:
            conn.commit()
            result = {'success': True, 'affected_rows': cursor.rowcount}
        
        cursor.close()
        conn.close()
        return result
    except mysql.connector.Error as err:
        print(f"Error: {err}")
        if conn:
            conn.close()
        return None

# ============================================
# HOME PAGE
# ============================================
@app.route('/')
def index():
    # Get statistics
    stats = {}
    stats['total_books'] = execute_query("SELECT COUNT(*) as count FROM BOOK", fetch_one=True)['count']
    stats['available_copies'] = execute_query("SELECT SUM(Available_Copies) as count FROM BOOK", fetch_one=True)['count']
    stats['total_members'] = execute_query("SELECT COUNT(*) as count FROM MEMBER", fetch_one=True)['count']
    stats['active_loans'] = execute_query("SELECT COUNT(*) as count FROM LOAN WHERE Status = 'Active'", fetch_one=True)['count']
    stats['overdue_loans'] = execute_query("SELECT COUNT(*) as count FROM LOAN WHERE Status = 'Overdue'", fetch_one=True)['count']
    
    # Get featured books (first 8)
    books = execute_query("""
        SELECT B.*, C.Category_Name,
               GROUP_CONCAT(A.Name SEPARATOR ', ') as Authors
        FROM BOOK B
        LEFT JOIN CATEGORY C ON B.Category_ID = C.Category_ID
        LEFT JOIN BOOK_AUTHOR BA ON B.ISBN = BA.ISBN
        LEFT JOIN AUTHOR A ON BA.Author_ID = A.Author_ID
        GROUP BY B.ISBN
        ORDER BY B.Title
        LIMIT 8
    """, fetch_all=True)
    
    return render_template('index.html', stats=stats, books=books)

# ============================================
# BROWSE BOOKS
# ============================================
@app.route('/books')
def browse_books():
    search = request.args.get('search', '')
    category_id = request.args.get('category', '')
    
    query = """
        SELECT B.*, C.Category_Name,
               GROUP_CONCAT(A.Name SEPARATOR ', ') as Authors
        FROM BOOK B
        LEFT JOIN CATEGORY C ON B.Category_ID = C.Category_ID
        LEFT JOIN BOOK_AUTHOR BA ON B.ISBN = BA.ISBN
        LEFT JOIN AUTHOR A ON BA.Author_ID = A.Author_ID
        WHERE 1=1
    """
    params = []
    
    if search:
        query += " AND (B.Title LIKE %s OR A.Name LIKE %s)"
        search_param = f"%{search}%"
        params.extend([search_param, search_param])
    
    if category_id:
        query += " AND B.Category_ID = %s"
        params.append(category_id)
    
    query += " GROUP BY B.ISBN ORDER BY B.Title"
    
    books = execute_query(query, tuple(params) if params else None, fetch_all=True)
    categories = execute_query("SELECT * FROM CATEGORY ORDER BY Category_Name", fetch_all=True)
    
    return render_template('browse_books.html', books=books, categories=categories, 
                         search=search, selected_category=category_id)

# ============================================
# ISSUE BOOK
# ============================================
@app.route('/issue-book', methods=['GET', 'POST'])
def issue_book():
    if request.method == 'POST':
        isbn = request.form['isbn']
        member_id = request.form['member_id']
        staff_id = 1  # Default staff ID
        
        # Check if book is available
        book = execute_query("SELECT Available_Copies, Title FROM BOOK WHERE ISBN = %s", (isbn,), fetch_one=True)
        
        if not book or book['Available_Copies'] <= 0:
            flash('Book is not available for borrowing.', 'danger')
            return redirect(url_for('issue_book'))
        
        # Check member's fines
        member = execute_query(
            "SELECT Total_Fine, Membership_Type, Name FROM MEMBER WHERE Member_ID = %s", 
            (member_id,), fetch_one=True
        )
        
        if member['Total_Fine'] > 500:
            flash('Cannot issue book. Member has outstanding fines exceeding ₹500.', 'danger')
            return redirect(url_for('issue_book'))
        
        # Calculate due date
        loan_days = {'Student': 14, 'Faculty': 30, 'General': 7}
        days = loan_days.get(member['Membership_Type'], 14)
        due_date = (datetime.now() + timedelta(days=days)).strftime('%Y-%m-%d')
        
        # Create loan and update book
        conn = get_db_connection()
        if conn:
            try:
                cursor = conn.cursor()
                
                # Insert loan
                cursor.execute("""
                    INSERT INTO LOAN (ISBN, Member_ID, Staff_ID, Due_Date, Status)
                    VALUES (%s, %s, %s, %s, 'Active')
                """, (isbn, member_id, staff_id, due_date))
                
                # Update book availability
                cursor.execute("""
                    UPDATE BOOK SET Available_Copies = Available_Copies - 1
                    WHERE ISBN = %s
                """, (isbn,))
                
                conn.commit()
                cursor.close()
                conn.close()
                
                flash(f"Book '{book['Title']}' issued successfully to {member['Name']}! Due date: {due_date}", 'success')
                return redirect(url_for('view_loans'))
            except Exception as e:
                conn.rollback()
                flash(f'Error issuing book: {str(e)}', 'danger')
                if conn:
                    conn.close()
    
    # GET request - show form
    books = execute_query("""
        SELECT B.ISBN, B.Title, B.Available_Copies,
               GROUP_CONCAT(A.Name SEPARATOR ', ') as Authors
        FROM BOOK B
        LEFT JOIN BOOK_AUTHOR BA ON B.ISBN = BA.ISBN
        LEFT JOIN AUTHOR A ON BA.Author_ID = A.Author_ID
        WHERE B.Available_Copies > 0
        GROUP BY B.ISBN
        ORDER BY B.Title
    """, fetch_all=True)
    
    members = execute_query("""
        SELECT Member_ID, Name, Email, Membership_Type, Total_Fine 
        FROM MEMBER 
        ORDER BY Name
    """, fetch_all=True)
    
    return render_template('issue_book.html', books=books, members=members)

# ============================================
# RETURN BOOK
# ============================================
@app.route('/return-book', methods=['GET', 'POST'])
def return_book():
    if request.method == 'POST':
        loan_id = request.form['loan_id']
        
        # Get loan details
        loan = execute_query("""
            SELECT L.*, M.Membership_Type, B.Title
            FROM LOAN L
            JOIN MEMBER M ON L.Member_ID = M.Member_ID
            JOIN BOOK B ON L.ISBN = B.ISBN
            WHERE L.Loan_ID = %s AND L.Status = 'Active'
        """, (loan_id,), fetch_one=True)
        
        if not loan:
            flash('Loan not found or already returned.', 'danger')
            return redirect(url_for('return_book'))
        
        # Calculate fine
        return_date = datetime.now().date()
        due_date = loan['Due_Date']
        fine = 0
        
        if return_date > due_date:
            days_overdue = (return_date - due_date).days
            fine_rates = {'Student': 5, 'Faculty': 3, 'General': 10}
            daily_rate = fine_rates.get(loan['Membership_Type'], 5)
            fine = min(days_overdue * daily_rate, 1000)
        
        # Update database
        conn = get_db_connection()
        if conn:
            try:
                cursor = conn.cursor()
                
                # Update loan
                cursor.execute("""
                    UPDATE LOAN 
                    SET Return_Date = CURDATE(), Fine_Amount = %s, Status = 'Returned'
                    WHERE Loan_ID = %s
                """, (fine, loan_id))
                
                # Update book availability
                cursor.execute("""
                    UPDATE BOOK SET Available_Copies = Available_Copies + 1
                    WHERE ISBN = %s
                """, (loan['ISBN'],))
                
                # Update member's fine
                if fine > 0:
                    cursor.execute("""
                        UPDATE MEMBER SET Total_Fine = Total_Fine + %s
                        WHERE Member_ID = %s
                    """, (fine, loan['Member_ID']))
                
                conn.commit()
                cursor.close()
                conn.close()
                
                fine_msg = f" Fine charged: ₹{fine:.2f}" if fine > 0 else " No fine (returned on time)"
                flash(f"Book '{loan['Title']}' returned successfully!{fine_msg}", 'success')
                return redirect(url_for('view_loans'))
            except Exception as e:
                conn.rollback()
                flash(f'Error returning book: {str(e)}', 'danger')
                if conn:
                    conn.close()
    
    # GET request - show active loans
    active_loans = execute_query("""
        SELECT L.*, B.Title, M.Name as Member_Name, M.Membership_Type,
               DATEDIFF(CURDATE(), L.Due_Date) as Days_Overdue
        FROM LOAN L
        JOIN BOOK B ON L.ISBN = B.ISBN
        JOIN MEMBER M ON L.Member_ID = M.Member_ID
        WHERE L.Status = 'Active'
        ORDER BY L.Due_Date ASC
    """, fetch_all=True)
    
    # Calculate estimated fines
    for loan in active_loans:
        if loan['Days_Overdue'] > 0:
            fine_rates = {'Student': 5, 'Faculty': 3, 'General': 10}
            daily_rate = fine_rates.get(loan['Membership_Type'], 5)
            loan['Estimated_Fine'] = min(loan['Days_Overdue'] * daily_rate, 1000)
        else:
            loan['Estimated_Fine'] = 0
    
    return render_template('return_book.html', active_loans=active_loans)

# ============================================
# VIEW LOANS
# ============================================
@app.route('/loans')
def view_loans():
    status_filter = request.args.get('status', 'all')
    
    query = """
        SELECT L.*, B.Title, M.Name as Member_Name, S.Name as Staff_Name
        FROM LOAN L
        JOIN BOOK B ON L.ISBN = B.ISBN
        JOIN MEMBER M ON L.Member_ID = M.Member_ID
        JOIN STAFF S ON L.Staff_ID = S.Staff_ID
    """
    
    if status_filter != 'all':
        query += f" WHERE L.Status = '{status_filter}'"
    
    query += " ORDER BY L.Issue_Date DESC"
    
    loans = execute_query(query, fetch_all=True)
    
    return render_template('view_loans.html', loans=loans, status_filter=status_filter)

# ============================================
# ADD BOOK
# ============================================
@app.route('/add-book', methods=['GET', 'POST'])
def add_book():
    if request.method == 'POST':
        isbn = request.form['isbn']
        title = request.form['title']
        publisher = request.form['publisher']
        year = request.form['publication_year']
        copies = request.form['total_copies']
        category_id = request.form['category_id']
        
        result = execute_query("""
            INSERT INTO BOOK (ISBN, Title, Publisher, Publication_Year, 
                             Total_Copies, Available_Copies, Category_ID)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (isbn, title, publisher, year, copies, copies, category_id))
        
        if result:
            flash(f"Book '{title}' added successfully!", 'success')
            return redirect(url_for('browse_books'))
        else:
            flash('Error adding book. ISBN might already exist.', 'danger')
    
    categories = execute_query("SELECT * FROM CATEGORY ORDER BY Category_Name", fetch_all=True)
    return render_template('add_book.html', categories=categories)

# ============================================
# ADD MEMBER
# ============================================
@app.route('/add-member', methods=['GET', 'POST'])
def add_member():
    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        phone = request.form['phone']
        address = request.form.get('address', '')
        membership_type = request.form['membership_type']
        
        result = execute_query("""
            INSERT INTO MEMBER (Name, Email, Phone, Address, Membership_Type)
            VALUES (%s, %s, %s, %s, %s)
        """, (name, email, phone, address, membership_type))
        
        if result:
            flash(f"Member '{name}' added successfully!", 'success')
            return redirect(url_for('index'))
        else:
            flash('Error adding member. Email might already exist.', 'danger')
    
    return render_template('add_member.html')

# ============================================
# REPORTS
# ============================================
@app.route('/reports')
def reports():
    # Most borrowed books
    most_borrowed = execute_query("""
        SELECT B.Title, COUNT(L.Loan_ID) as Loan_Count,
               GROUP_CONCAT(DISTINCT A.Name SEPARATOR ', ') as Authors
        FROM LOAN L
        JOIN BOOK B ON L.ISBN = B.ISBN
        LEFT JOIN BOOK_AUTHOR BA ON B.ISBN = BA.ISBN
        LEFT JOIN AUTHOR A ON BA.Author_ID = A.Author_ID
        GROUP BY B.ISBN
        ORDER BY Loan_Count DESC
        LIMIT 10
    """, fetch_all=True)
    
    # Overdue books
    overdue_books = execute_query("""
        SELECT L.*, B.Title, M.Name as Member_Name, M.Phone,
               DATEDIFF(CURDATE(), L.Due_Date) as Days_Overdue
        FROM LOAN L
        JOIN BOOK B ON L.ISBN = B.ISBN
        JOIN MEMBER M ON L.Member_ID = M.Member_ID
        WHERE L.Status = 'Active' AND L.Due_Date < CURDATE()
        ORDER BY Days_Overdue DESC
    """, fetch_all=True)
    
    # Members with fines
    members_with_fines = execute_query("""
        SELECT Name, Email, Phone, Total_Fine, Membership_Type
        FROM MEMBER
        WHERE Total_Fine > 0
        ORDER BY Total_Fine DESC
    """, fetch_all=True)
    
    return render_template('reports.html', 
                         most_borrowed=most_borrowed,
                         overdue_books=overdue_books,
                         members_with_fines=members_with_fines)

# ============================================
# RUN APPLICATION
# ============================================
if __name__ == '__main__':
    print("=" * 60)
    print("Library Management System - Python Flask")
    print("=" * 60)
    print("Server running on: http://localhost:5000")
    print("Press Ctrl+C to stop the server")
    print("=" * 60)
    app.run(debug=True, port=5000)
