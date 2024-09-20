// controllers/sellerController.js
const Seller = require('../models/sellerModels');
const jwt = require('jsonwebtoken');
const { validationResult } = require('express-validator');
const bcrypt = require('bcryptjs');

// Signup Controller
const signup = async (req, res) => {
  // Handle validation results
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    // Extract error messages
    const extractedErrors = errors.array().map(err => err.msg);
    return res.status(400).json({ success: false, errors: extractedErrors });
  }

  try {
    const { name, email, password } = req.body;

    // Check for existing seller
    let existingSeller = await Seller.findOne({ email });
    if (existingSeller) {
      return res.status(400).json({ success: false, errors: ['Seller already exists with this email.'] });
    }

    // Validate that all fields are provided
    if (!req.file) {
      return res.status(400).json({ success: false, errors: ['ID Picture is required.'] });
    }

    // Hash the password before saving
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create a new seller
    const newSeller = new Seller({
      name,
      email,
      password: hashedPassword, // Store the hashed password
      idPicture: req.file.filename, // Store the filename
      isApproved: false, // Default to not approved
    });

    await newSeller.save();

    res.status(201).json({ success: true, data: 'Seller registered successfully! Waiting for admin approval.' });
  } catch (error) {
    console.error('Signup Controller Error:', error); // Enhanced error logging
    res.status(500).json({ success: false, errors: ['Server error.'] });
  }
};

// Login Controller
const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const seller = await Seller.findOne({ email });

    if (!seller) {
      return res.status(400).json({ success: false, errors: ['User not found.'] });
    }

    // Compare hashed passwords
    const isMatch = await bcrypt.compare(password, seller.password);
    if (!isMatch) {
      return res.status(400).json({ success: false, errors: ['Invalid Credentials.'] });
    }

    // Check if the seller is approved by admin
    if (!seller.isApproved) {
      return res.status(200).json({ success: false, errors: ['Your account is pending admin approval.'] });
    }

    // If approved, generate token
    const token = jwt.sign({ id: seller.id }, process.env.JWT_SECRET, { expiresIn: '1h' });
    res.json({ success: true, token });
  } catch (err) {
    console.error('Login Controller Error:', err);
    res.status(500).json({ success: false, errors: ['Server Error.'] });
  }
};

const getPendingSellers = async (req, res) => {
  try {
    // Fetch all sellers where 'isApproved' is false
    const pendingSellers = await Seller.find({ isApproved: false });
    res.status(200).json(pendingSellers);
  } catch (error) {
    console.error('Error fetching pending sellers:', error);
    res.status(500).json({ success: false, message: 'Server error.' });
  }
};


module.exports = { signup, login, getPendingSellers };
