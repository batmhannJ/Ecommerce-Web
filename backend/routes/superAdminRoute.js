const express = require("express");
const router = express.Router();
const {
  approveAdmin,
  login,
} = require("../controllers/superAdminController");

// router.post('/signup', signup);
router.post("/login", login);
router.patch("/approve/:adminId", approveAdmin); // Add this line for approving admins


module.exports = router;
