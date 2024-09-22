// routes/sellerRoute.js
const express = require('express');
const router = express.Router();
const { signup, login, getPendingSellers } = require('../controllers/sellerController');
const multer = require('multer');
const path = require('path');
const { check } = require('express-validator');
const authMiddleware = require('../middleware/auth');
const Seller = require('../models/sellerModels'); // Import the Seller model
const bcrypt = require('bcrypt'); // Add this line
const jwt = require('jsonwebtoken'); // Import jsonwebtoken here

const generateAuthToken = (seller) => {
    const token = jwt.sign({ id: seller._id }, 'admin_token', { expiresIn: '1h' }); // Replace 'your_jwt_secret' with your secret key
    return token;
  };
// Configure Multer Storage
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
      cb(null, 'upload/'); // Ensure this directory exists
    },
    filename: function (req, file, cb) {
      cb(null, Date.now() + path.extname(file.originalname)); // e.g., 1631024800000.jpg
    },
  });

  // Initialize Multer
const upload = multer({ 
    storage: storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB file size limit
    fileFilter: function (req, file, cb) {
      const fileTypes = /jpeg|jpg|png/;
      const extname = fileTypes.test(path.extname(file.originalname).toLowerCase());
      const mimetype = fileTypes.test(file.mimetype);
      if (mimetype && extname) {
        return cb(null, true);
      } else {
        cb(new Error('Only images are allowed (jpeg, jpg, png)'));
      }
    }
  });
// Validation Rules for Signup
const signupValidation = [
    check('name', 'Name is required').notEmpty(),
    check('email', 'Please include a valid email').isEmail(),
    check('password', 'Password must be at least 8 characters long and include at least one capital letter.')
      .isLength({ min: 8 })
      .matches(/^(?=.*[A-Z]).{8,}$/),
  ];
  
  // Signup Route
  router.post('/signup', upload.single('idPicture'), signupValidation, signup);
  
  // Login Route
  router.post('/login', async (req, res) => {
    const { email, password } = req.body;
  
    try {
      const seller = await Seller.findOne({ email });
  
      if (!seller) {
        return res.status(400).json({ success: false, message: 'Seller not found' });
      }
  
      // Check password
      const isMatch = await bcrypt.compare(password, seller.password);
      if (!isMatch) {
        return res.status(400).json({ success: false, message: 'Invalid credentials' });
      }
  
      // Include the isApproved status in the response
      const token = generateAuthToken(seller); // Assume you have a function to generate a JWT
      res.status(200).json({
        success: true,
        token,
        seller: {
          _id: seller._id,
          name: seller.name,
          email: seller.email,
          isApproved: seller.isApproved,
        },
      });
    } catch (error) {
      console.error('Login error:', error);
      res.status(500).json({ success: false, message: 'Server error' });
    }
  });
  

  router.get('/pending', getPendingSellers);
  router.patch('/:id/approve', async (req, res) => {
    try {
      const { id } = req.params;
  
      // Find the seller by ID and update 'isApproved' to true
      const updatedSeller = await Seller.findByIdAndUpdate(
        id,
        { isApproved: true },
        { new: true } // Return the updated document
      );
  
      if (!updatedSeller) {
        return res.status(404).json({ success: false, message: 'Seller not found.' });
      }
  
      res.status(200).json({ success: true, seller: updatedSeller });
    } catch (error) {
      console.error('Error approving seller:', error);
      res.status(500).json({ success: false, message: 'Server error.' });
    }
  });
  
  router.delete('/:id', authMiddleware, async (req, res) => {
    try {
      const { id } = req.params;
      const deletedSeller = await Seller.findByIdAndDelete(id);
  
      if (!deletedSeller) {
        return res.status(404).json({ success: false, errors: ['Seller not found'] });
      }
  
      res.json({ success: true, message: 'Seller deleted successfully.' });
    } catch (err) {
      console.error('Error deleting seller:', err);
      res.status(500).json({ success: false, errors: ['Server Error'] });
    }
  });

module.exports = router;
