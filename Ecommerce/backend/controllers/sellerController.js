// controllers/sellerController.js
const Seller = require('../models/sellerModels');
const jwt = require('jsonwebtoken');

const signup = async (req, res) => {
  try {
    const { username, email, password } = req.body;
    let seller = await Seller.findOne({ email });
    if (seller) {
      return res.status(400).json({ success: false, errors: "Existing User Found" });
    }

    seller = new Seller({ username, email, password });
    await seller.save();

    const token = jwt.sign({ id: seller.id }, 'secret_ecom');
    res.json({ success: true, token });
  } catch (err) {
    res.status(500).json({ success: false, errors: 'Server Error' });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const seller = await Seller.findOne({ email });
    if (!seller || seller.password !== password) {
      return res.status(400).json({ success: false, errors: "Invalid Credentials" });
    }

    const token = jwt.sign({ id: seller.id }, 'secret_ecom');
    res.json({ success: true, token });
  } catch (err) {
    res.status(500).json({ success: false, errors: 'Server Error' });
  }
};

module.exports = { signup, login };
