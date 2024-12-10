import React, { useState } from 'react';
import { adminLogin, adminSignup } from '../../services/api'; // Add adminSignup API
import { FaEye, FaEyeSlash } from "react-icons/fa";
import { toast } from 'react-toastify';
import { useNavigate } from 'react-router-dom';
import './LoginSignup.css'; // Import your CSS file

const LoginSignup = () => {
  const [formData, setFormData] = useState({
    email: '',
    password: '',
  });
  const [isSignup, setIsSignup] = useState(false); // Toggle between login and signup
  const [showPassword, setShowPassword] = useState(false); // Password visibility
  const navigate = useNavigate();

  const togglePasswordVisibility = () => {
    setShowPassword((prev) => !prev);
  };

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const { email, password } = formData;
  
    if (!email || !password) {
      toast.error('Please fill in all fields.');
      return;
    }
  
    try {
      if (isSignup) {
        // Signup logic
        const response = await adminSignup({ email, password }); // Call the signup API
        if (response.success) {
          toast.success('Signup successful! Wait for the admin to approve your request.');
          setIsSignup(false); // Switch to login mode after signup
        } else {
          toast.error(response.errors || 'Signup failed.'); // Use 'errors' here
        }
      } else {
        // Login logic
        const response = await adminLogin({ email, password }); // Call the login API
        if (response.success) {
          localStorage.setItem('admin_token', response.token); // Save token
          toast.success('Login successful! Redirecting...');
          navigate('/admin/dashboard'); // Navigate to admin dashboard
          window.location.reload(); // Optional: Reload if necessary
        } else {
          toast.error(response.errors || 'Login failed.'); // Use 'errors' here
        }
      }
    } catch (error) {
      console.error('Error:', error);
      toast.error(error.response?.data?.errors || 'An error occurred.'); // Use 'errors' here as well
    }
  };
  

  return (
    <div className="login-container">
      <div className="login-box">
        <h1>{isSignup ? 'Admin Signup' : 'Admin Login'}</h1>
        <form onSubmit={handleSubmit}>
          <div>
            <label>Email:</label>
            <input
              type="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              required
            />
          </div>
          <div style={{ position: 'relative' }}>
  <label>Password:</label>
  <input
    type={showPassword ? 'text' : 'password'}
    name="password"
    value={formData.password}
    onChange={(e) => {
      const value = e.target.value;
      setFormData({ ...formData, password: value });

      // Validate password: at least one capital letter, between 8 and 20 characters
      const passwordRegex = /^(?=.*[A-Z]).{8,20}$/; // At least one capital letter and between 8 to 20 characters
      if (!passwordRegex.test(value)) {
        setPasswordError('Password must be between 8 and 20 characters and include at least one capital letter.');
      } else {
        setPasswordError(''); // Clear error if valid
      }
    }}
    required
  />
           <span
  onClick={togglePasswordVisibility}
  style={{
    cursor: 'pointer',
    position: 'absolute',
    right: window.innerWidth <= 500 ? '5px' : '10px', // Adjust right margin for smaller screens
    top: window.innerWidth <= 500 ? '55%' : '60%',   // Adjust top position for smaller screens
    transform: 'translateY(-50%)',
    fontSize: window.innerWidth <= 500 ? '16px' : '20px', // Adjust font size
  }}
>
  {showPassword ? <FaEyeSlash /> : <FaEye />}
</span>

          </div>
          <button type="submit">{isSignup ? 'Sign up' : 'Log in'}</button>
        </form>
        <p>
          {isSignup ? (
            <>
              Already have an account?{' '}
              <span
                className="link"
                onClick={() => setIsSignup(false)}
              >
                Log in
              </span>
            </>
          ) : (
            <>
              Don't have an account?{' '}
              <span
                className="link"
                onClick={() => setIsSignup(true)}
              >
                Sign up
              </span>
            </>
          )}
        </p>
      </div>
    </div>
  );
};

export default LoginSignup;
