const express = require("express"); // Import express
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const SuperAdminUser = require("../models/superAdminModel");
const authMiddleware = require("../middleware/auth");
require("dotenv").config();

const router = express.Router(); // Create a new router

const approveAdmin = async (req, res) => {
    try {
      const { adminId } = req.params;
  
      const admin = await AdminUser.findById(adminId);
      if (!admin) {
        return res.status(404).json({ success: false, errors: ["Admin not found."] });
      }
  
      admin.isApproved = true;
      await admin.save();
  
      res.status(200).json({ success: true, data: "Admin approved successfully!" });
    } catch (error) {
      console.error("Approve Admin Error:", error);
      res.status(500).json({ success: false, errors: ["Server error."] });
    }
  };

  const login = async (req, res) => {
    try {
      const { email, password } = req.body; // Get email and password from the request body
      const admin = await SuperAdminUser.findOne({ email }); // Find the admin by email
  
      // Check if admin exists
      if (!admin) {
        return res
          .status(400)
          .json({ success: false, errors: "Invalid email or password" });
      }
  
      // Check if the provided password matches the stored password (plain text comparison)
      if (password !== admin.password) {
        return res
          .status(400)
          .json({ success: false, errors: "Invalid email or password" });
      }
  
      // Generate a JWT token if login is successful
      const token = jwt.sign(
        { id: admin._id, role: admin.role },
        process.env.JWT_SECRET,
        { expiresIn: "1h" }
      );
      console.log({ success: true, token, adminId: admin._id });
      res.json({ success: true, token, adminId: admin._id });
      // Send admin ID back to client
    } catch (error) {
      console.error("Login Error:", error);
      res
        .status(500)
        .json({ success: false, errors: "An error occurred during login" });
    }
  };

  
  module.exports = {
    login,
    approveAdmin, // Export the router so it can be used in the routes
  };