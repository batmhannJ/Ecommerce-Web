const mongoose = require('mongoose');

const ProductSchema = new mongoose.Schema({
  id: {
    type: Number,
    required: true,
  },
  name: {
    type: String,
    required: true,
  },
  image: {
    type: String,
    required: true,
  },
  category: {
    type: String,
    required: true,
  },
  new_price: {
    type: Number,
    required: true,
  },
  old_price: {
    type: Number,
    required: true,
  },
  size: {
    S: { stock: { type: Number, default: 0 } },
    M: { stock: { type: Number, default: 0 } },
    L: { stock: { type: Number, default: 0 } },
    XL: { stock: { type: Number, default: 0 } },
  },
  stock: {
    type: Number, // This will store the total stock
    required: true,
  },
  date: {
    type: Date,
    default: Date.now,
  },
  available: {
    type: Boolean,
    default: true
  },
});

const Product = mongoose.model('Product', ProductSchema);

module.exports = Product;
