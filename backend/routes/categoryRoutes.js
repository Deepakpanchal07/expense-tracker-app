const express = require('express');
const router = express.Router();
const Category = require('../models/Category');

// GET all categories
router.get('/', async (req, res) => {
  try {
    const categories = await Category.find().sort({ name: 1 });
    res.json(categories);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// CREATE a category
router.post('/', async (req, res) => {
  try {
    const { id, name, icon_code, color_value, is_expense, is_default } = req.body;
    const category = await Category.findOneAndUpdate(
      { id },
      { id, name, icon_code, color_value, is_expense, is_default },
      { upsert: true, new: true }
    );
    res.status(201).json(category);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// UPDATE a category
router.put('/:id', async (req, res) => {
  try {
    const updated = await Category.findOneAndUpdate(
      { id: req.params.id },
      req.body,
      { new: true }
    );
    if (!updated) {
      return res.status(404).json({ message: 'Category not found' });
    }
    res.json(updated);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// DELETE a category
router.delete('/:id', async (req, res) => {
  try {
    const deleted = await Category.findOneAndDelete({ id: req.params.id });
    if (!deleted) {
      return res.status(404).json({ message: 'Category not found' });
    }
    res.json({ message: 'Category deleted successfully', id: req.params.id });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
