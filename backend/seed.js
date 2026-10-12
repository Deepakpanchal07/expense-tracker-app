const mongoose = require('mongoose');
const Category = require('./models/Category');

const seedDefaultData = async () => {
  try {
    const categoryCount = await Category.countDocuments();
    if (categoryCount === 0) {
      console.log('🌱 Seeding default categories into MongoDB...');
      const defaultCategories = [
        { id: 'cat_food', name: 'Food & Dining', icon_code: 0xe532, color_value: 0xffff6b6b, is_expense: true, is_default: true },
        { id: 'cat_groceries', name: 'Groceries', icon_code: 0xe59c, color_value: 0xfffa8231, is_expense: true, is_default: true },
        { id: 'cat_transport', name: 'Transport & Fuel', icon_code: 0xe1d7, color_value: 0xff45aaf2, is_expense: true, is_default: true },
        { id: 'cat_shopping', name: 'Shopping', icon_code: 0xf0170, color_value: 0xffa55eea, is_expense: true, is_default: true },
        { id: 'cat_housing', name: 'Housing & Rent', icon_code: 0xe318, color_value: 0xff26de81, is_expense: true, is_default: true },
        { id: 'cat_entertainment', name: 'Entertainment', icon_code: 0xe406, color_value: 0xfffd9644, is_expense: true, is_default: true },
        { id: 'cat_bills', name: 'Bills & Utilities', icon_code: 0xf00b3, color_value: 0xff2bcbba, is_expense: true, is_default: true },
        { id: 'cat_health', name: 'Healthcare', icon_code: 0xe3ac, color_value: 0xfffc5c65, is_expense: true, is_default: true },
        { id: 'cat_education', name: 'Education', icon_code: 0xe559, color_value: 0xff4b7bec, is_expense: true, is_default: true },
        { id: 'cat_other_exp', name: 'General / Other', icon_code: 0xe404, color_value: 0xff778ca3, is_expense: true, is_default: true },
        { id: 'cat_salary', name: 'Monthly Salary', icon_code: 0xe041, color_value: 0xff20bf6b, is_expense: false, is_default: true },
        { id: 'cat_freelance', name: 'Freelance & Projects', icon_code: 0xe362, color_value: 0xff0fb9b1, is_expense: false, is_default: true },
        { id: 'cat_investment', name: 'Investments & Stocks', icon_code: 0xe661, color_value: 0xff2d98da, is_expense: false, is_default: true },
        { id: 'cat_bonus', name: 'Gifts & Bonus', icon_code: 0xe138, color_value: 0xffff9ff3, is_expense: false, is_default: true },
      ];
      await Category.insertMany(defaultCategories);
      console.log('✅ Default categories seeded.');
    }
    // Starting with clean zero data for transactions as requested
  } catch (error) {
    console.error('Error seeding data:', error.message);
  }
};

module.exports = seedDefaultData;
