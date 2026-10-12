const mongoose = require('mongoose');

const TransactionSchema = new mongoose.Schema(
  {
    id: {
      type: String,
      required: true,
      unique: true,
    },
    title: {
      type: String,
      required: true,
      trim: true,
    },
    amount: {
      type: Number,
      required: true,
      min: 0,
    },
    date: {
      type: Date,
      required: true,
      default: Date.now,
    },
    category_id: {
      type: String,
      required: true,
    },
    category_name: {
      type: String,
      required: true,
    },
    category_icon_code: {
      type: Number,
      required: true,
    },
    category_color_value: {
      type: Number,
      required: true,
    },
    type: {
      type: String,
      enum: ['expense', 'income'],
      required: true,
    },
    payment_method: {
      type: String,
      default: 'Cash',
    },
    notes: {
      type: String,
      default: '',
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Transaction', TransactionSchema);
