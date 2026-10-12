# Expense Tracker Backend (Node.js + Express + MongoDB)

RESTful API backend for the Flutter Expense Tracker application.

## 🛠️ Tech Stack
- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose ODM
- **Middleware**: CORS, Morgan, Dotenv

## 🚀 Getting Started

### 1. Prerequisites
Ensure MongoDB is running locally on `mongodb://127.0.0.1:27017` or update `MONGO_URI` in `.env`.

### 2. Install Dependencies
```bash
cd backend
npm install
```

### 3. Start the Server
```bash
npm start
# or for development with auto-reload:
npm run dev
```

The server will start on `http://localhost:5000`.

## 📡 API Endpoints

### Health Check
- `GET /api/health`: Check server and database status

### Categories
- `GET /api/categories`: Retrieve all expense & income categories
- `POST /api/categories`: Create or upsert a category
- `PUT /api/categories/:id`: Update category
- `DELETE /api/categories/:id`: Delete a category

### Transactions
- `GET /api/transactions`: Retrieve all transactions (supports `?type=`, `?search=`, `?categoryId=`, `?sortBy=`)
- `GET /api/transactions/summary`: Retrieve overall financial calculations & category breakdown
- `POST /api/transactions`: Create or upsert a transaction
- `PUT /api/transactions/:id`: Update an existing transaction
- `DELETE /api/transactions/:id`: Delete a transaction

### Budgets
- `GET /api/budgets/:month/:year`: Get monthly budget limit
- `POST /api/budgets`: Set/update monthly budget limit
