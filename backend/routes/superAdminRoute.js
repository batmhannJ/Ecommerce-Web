const express = require("express");
const router = express.Router();
const {
  approveAdmin,
  login,
  getsuperAdminById,
  updateSuperAdmin,
} = require("../controllers/superAdminController");

// router.post('/signup', signup);
router.post("/login", login);
router.patch("/approve/:adminId", approveAdmin); // Add this line for approving admins
router.get("/superadmin/:id", getsuperAdminById);
router.patch("/editsuperadmin/:id", updateSuperAdmin);

module.exports = router;
