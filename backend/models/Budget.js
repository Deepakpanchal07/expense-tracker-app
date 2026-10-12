const mongoose = require('mongoose');

const BudgetSchema = new mongoose.Schema(
  {
    month: {
      type: Number,
      required: true,
      min: 1,
      max: 12,
    },
    year: {
      type: Number,
      required: true,
    },
    monthly_limit: {
      type: Number,
      required: true,
      min: 0,
    },
  },
  {
    timestamps: true,
  }
);

BudgetSchema.index({ month: 1, year: 1 }, { unique: true });

module.exports = mongoose.model('Budget', BudgetSchema);
