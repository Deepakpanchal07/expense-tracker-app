const express = require('express');
const router = express.Router();
const Transaction = require('../models/Transaction');

// GET all transactions with optional filter & search
router.get('/', async (req, res) => {
  try {
    const { type, search, categoryId, sortBy } = req.query;
    let query = {};

    if (type && ['expense', 'income'].includes(type)) {
      query.type = type;
    }

    if (categoryId) {
      query.category_id = categoryId;
    }

    if (search) {
      const searchRegex = new RegExp(search, 'i');
      query.$or = [
        { title: searchRegex },
        { category_name: searchRegex },
        { payment_method: searchRegex },
        { notes: searchRegex },
      ];
    }

    let sortOption = { date: -1 };
    if (sortBy === 'date_asc') sortOption = { date: 1 };
    else if (sortBy === 'amount_desc') sortOption = { amount: -1 };
    else if (sortBy === 'amount_asc') sortOption = { amount: 1 };

    const transactions = await Transaction.find(query).sort(sortOption);
    res.json(transactions);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET summary & analytics
router.get('/summary', async (req, res) => {
  try {
    const transactions = await Transaction.find();
    let totalIncome = 0;
    let totalExpense = 0;
    const categoryTotals = {};

    transactions.forEach((tx) => {
      if (tx.type === 'income') {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
        if (!categoryTotals[tx.category_name]) {
          categoryTotals[tx.category_name] = {
            category_id: tx.category_id,
            category_name: tx.category_name,
            color_value: tx.category_color_value,
            icon_code: tx.category_icon_code,
            amount: 0,
          };
        }
        categoryTotals[tx.category_name].amount += tx.amount;
      }
    });

    const categoryBreakdown = Object.values(categoryTotals).map((cat) => ({
      ...cat,
      percentage: totalExpense > 0 ? (cat.amount / totalExpense) * 100 : 0,
    }));

    res.json({
      totalIncome,
      totalExpense,
      balance: totalIncome - totalExpense,
      count: transactions.length,
      categoryBreakdown,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// CREATE transaction
router.post('/', async (req, res) => {
  try {
    const {
      id,
      title,
      amount,
      date,
      category_id,
      category_name,
      category_icon_code,
      category_color_value,
      type,
      payment_method,
      notes,
    } = req.body;

    const transaction = await Transaction.findOneAndUpdate(
      { id },
      {
        id,
        title,
        amount,
        date: date ? new Date(date) : new Date(),
        category_id,
        category_name,
        category_icon_code,
        category_color_value,
        type,
        payment_method: payment_method || 'Cash',
        notes: notes || '',
      },
      { upsert: true, new: true }
    );

    res.status(201).json(transaction);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// UPDATE transaction
router.put('/:id', async (req, res) => {
  try {
    const updateData = { ...req.body };
    if (updateData.date) {
      updateData.date = new Date(updateData.date);
    }

    const updated = await Transaction.findOneAndUpdate(
      { id: req.params.id },
      updateData,
      { new: true }
    );

    if (!updated) {
      return res.status(404).json({ message: 'Transaction not found' });
    }
    res.json(updated);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// DELETE transaction
router.delete('/:id', async (req, res) => {
  try {
    const deleted = await Transaction.findOneAndDelete({ id: req.params.id });
    if (!deleted) {
      return res.status(404).json({ message: 'Transaction not found' });
    }
    res.json({ message: 'Transaction deleted successfully', id: req.params.id });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
