const express = require('express');
const router = express.Router();
const Users = require('../models/userModels');

router.post('/login', async (req, res) => {
    const { email, password, recaptchaToken } = req.body;

    // First, check if the CAPTCHA token is present
    if (!recaptchaToken) {
        return res.status(400).json({ success: false, errors: "Please complete the CAPTCHA." });
    }

    const secretKey = "6LcCKEcqAAAAAPPobVGRQtrDKHWj50SLLr2WzCUV";  // Your reCAPTCHA secret key
    const verificationUrl = `https://www.google.com/recaptcha/api/siteverify?secret=${secretKey}&response=${recaptchaToken}`;
    try {
        // Verify reCAPTCHA
        const captchaResponse = await axios.post(verificationUrl);
        console.log("CAPTCHA response:", captchaResponse.data); 
        const { success: captchaSuccess } = captchaResponse.data;

        if (!captchaSuccess) {
            return res.status(400).json({ success: false, errors: "CAPTCHA verification failed." });
        }

        const user = await Users.findOne({ email });
        if (!user) {
            return res.status(400).json({ success: false, errors: "User not found" });
        }
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ success: false, errors: "Invalid credentials" });
        }
        const token = jwt.sign({ id: user._id }, 'your_jwt_secret', { expiresIn: '1h' });
        res.json({ success: true, token, user: { id: user._id, username: user.username, email: user.email } });
    } catch (error) {
        console.error("Error logging in user:", error);
        res.status(500).json({ error: "Failed to log in user" });
    }
});

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
