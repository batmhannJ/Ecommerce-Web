const express = require("express");
const router = express.Router();

const AdminUser = require("../models/adminUserModel");
const {
  signup,
  login,
  getAdminById,
  updateAdmin,
  getAdmins,
  searchAdmin,
} = require("../controllers/adminController");

// router.post('/signup', signup);
router.post("/login", login);
router.post("/signup", signup); // Add this line for admin signup
router.get("/admin/:id", getAdminById);
router.patch("/editadmin/:id", updateAdmin);
router.get("/admins", getAdmins);
router.get("/api/admin/search", searchAdmin);

router.delete("/deleteadmin/:id", async (req, res) => {
  const { id } = req.params;
  try {
    await AdminUser.findByIdAndDelete(id);
    res.json({ success: true });
  } catch (error) {
    console.error("Error deleting user:", error);
    res.status(500).json({ error: "Failed to delete user" });
  }
});


module.exports = router;
