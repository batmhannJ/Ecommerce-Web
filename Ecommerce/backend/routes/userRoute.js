const express = require('express');
const router = express.Router();
const Users = require('../models/userModels');

// Fetch all users
router.get('/users', async (req, res) => {
    try {
        const users = await Users.find({});
        res.json(users);
    } catch (error) {
        console.error("Error fetching users:", error);
        res.status(500).json({ error: "Failed to fetch users" });
    }
});

// Edit user
router.patch('/edituser/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const updatedUser = await Users.findByIdAndUpdate(id, req.body, { new: true });
        res.json(updatedUser);
    } catch (error) {
        console.error("Error updating user:", error);
        res.status(500).json({ error: "Failed to update user" });
    }
});

// Delete user
router.delete('/deleteuser/:id', async (req, res) => {
    const { id } = req.params;
    try {
        await Users.findByIdAndDelete(id);
        res.json({ success: true });
    } catch (error) {
        console.error("Error deleting user:", error);
        res.status(500).json({ error: "Failed to delete user" });
    }
});

// Add this route to your existing router file
router.get('/users/search', async (req, res) => {
    const { term } = req.query;
    try {
        const users = await Users.find({
            $or: [
                { name: new RegExp(term, 'i') },
                { email: new RegExp(term, 'i') }
            ]
        });
        res.json(users);
    } catch (error) {
        console.error("Error searching users:", error);
        res.status(500).json({ error: "Failed to search users" });
    }
});


module.exports = router;
