const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const AdminUser = require('../models/adminUserModel');
require('dotenv').config();

// Sign Up for Admin
const signup = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    const existingAdmin = await AdminUser.findOne({ email });
    if (existingAdmin) {
      return res.status(400).json({ success: false, errors: 'Admin already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const admin = new AdminUser({
      name,
      email,
      password: hashedPassword,
    });

    await admin.save();

    const token = jwt.sign({ id: admin._id, role: admin.role }, process.env.JWT_SECRET, { expiresIn: '1h' });
    res.json({ success: true, token });
  } catch (error) {
    console.error('Signup Error:', error); 
    res.status(500).json({ success: false, errors: 'An error occurred during signup' });
  }
};

// Login for Admin
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const admin = await AdminUser.findOne({ email });
    if (!admin) {
      return res.status(400).json({ success: false, errors: 'Invalid email or password' });
    }

    const isMatch = await bcrypt.compare(password, admin.password);
    if (!isMatch) {
      return res.status(400).json({ success: false, errors: 'Invalid email or password' });
    }

    const token = jwt.sign({ id: admin._id, role: admin.role }, process.env.JWT_SECRET, { expiresIn: '1h' });
    res.json({ success: true, token });
  } catch (error) {
    console.error('Login Error:', error);
    res.status(500).json({ success: false, errors: 'An error occurred during login' });
  }
};

module.exports = { login };
