const express = require('express');
const router = express.Router();
const Budget = require('../models/Budget');

// GET budget for a specific month and year
router.get('/:month/:year', async (req, res) => {
  try {
    const { month, year } = req.params;
    const budget = await Budget.findOne({
      month: parseInt(month, 10),
      year: parseInt(year, 10),
    });

    if (budget) {
      return res.json(budget);
    }
    // Default budget limit starts at 0 until user sets one
    res.json({
      month: parseInt(month, 10),
      year: parseInt(year, 10),
      monthly_limit: 0.0,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// SET / UPDATE budget
router.post('/', async (req, res) => {
  try {
    const { month, year, monthly_limit } = req.body;
    const budget = await Budget.findOneAndUpdate(
      { month: parseInt(month, 10), year: parseInt(year, 10) },
      {
        month: parseInt(month, 10),
        year: parseInt(year, 10),
        monthly_limit: parseFloat(monthly_limit),
      },
      { upsert: true, new: true }
    );
    res.json(budget);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

module.exports = router;
