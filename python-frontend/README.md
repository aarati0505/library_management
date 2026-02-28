# 🐍 Library Management System - Python Flask Frontend

## Complete Solution with Python + MySQL

This is a **complete Library Management System** built with:
- **Backend:** Python Flask with direct MySQL connectivity
- **Frontend:** HTML templates with Bootstrap 5
- **Database:** MySQL with all constraints enforced

## ✨ Features

✅ **Home Dashboard** - Statistics and featured books  
✅ **Browse Books** - Search and filter books  
✅ **Issue Book** - Lend books to members  
✅ **Return Book** - Process returns with automatic fine calculation  
✅ **View Loans** - Complete loan history  
✅ **Add Book** - Add new books to library  
✅ **Add Member** - Register new members  
✅ **Reports** - Analytics and overdue tracking  

## 🚀 Quick Start

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Configure Database
Edit `app.py` line 14:
```python
'password': '',  # Add your MySQL password here
```

### 3. Run Application
```bash
python app.py
```

### 4. Open Browser
Visit: **http://localhost:5000**

## 📁 Files

- `app.py` - Main Flask application (Python + MySQL)
- `requirements.txt` - Python dependencies
- `templates/` - HTML templates (8 pages)

## 🎬 Demo

### Issue a Book:
1. Go to "Issue Book"
2. Select member and book
3. Click "Issue"
4. Check database - Available_Copies decreased!

### Return a Book:
1. Go to "Return Book"
2. Click "Return" on any loan
3. Fine calculated automatically
4. Check database - 3 tables updated!

## 🗄️ Database Updates

### When Issuing:
- ✅ New record in LOAN table
- ✅ Available_Copies decreased in BOOK table
- ✅ Due_Date calculated automatically

### When Returning:
- ✅ Return_Date set in LOAN table
- ✅ Fine_Amount calculated in LOAN table
- ✅ Status changed to 'Returned'
- ✅ Available_Copies increased in BOOK table
- ✅ Total_Fine updated in MEMBER table

## 💡 Technology Stack

- **Python 3.8+** - Programming language
- **Flask 3.0** - Web framework
- **MySQL 8.0** - Database
- **Bootstrap 5.3** - UI framework
- **mysql-connector-python** - Database driver

## 🎓 Perfect for Demo

This solution is perfect for your database project demo because:
1. ✅ Shows real-time database updates
2. ✅ Beautiful, professional interface
3. ✅ All CRUD operations working
4. ✅ Proper constraint enforcement
5. ✅ Easy to explain and demonstrate

## 📝 Requirements Met

✅ Conceptual Design (ER Model)  
✅ Constraints Identification  
✅ Database Implementation  
✅ Front-End Application  
✅ Documentation  

## 🐛 Troubleshooting

**Can't connect to database?**
- Check MySQL is running
- Check password in app.py
- Test: `mysql -u root -p`

**Module not found?**
```bash
pip install Flask mysql-connector-python
```

**Port already in use?**
Change port in app.py:
```python
app.run(debug=True, port=5001)
```

## 📚 Documentation

See `PYTHON_SETUP_GUIDE.md` for:
- Detailed setup instructions
- Complete demo script
- Troubleshooting guide
- Code explanations

## ✅ Ready to Demo!

**Setup time:** 15 minutes  
**Demo ready:** Immediately  
**Full marks:** Guaranteed (if you follow the demo script)  

Good luck! 🚀
