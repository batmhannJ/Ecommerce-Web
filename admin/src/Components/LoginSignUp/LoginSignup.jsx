import React, { useState } from 'react';
import { adminLogin } from '../../services/api';
import { FaEye, FaEyeSlash } from "react-icons/fa";
import { toast } from 'react-toastify';
import { useNavigate } from 'react-router-dom';
import './LoginSignup.css'; // Import your CSS file

const LoginSignup = () => {
  const [formData, setFormData] = useState({
    email: '',
    password: '',
  });
  const [passwordError, setPasswordError] = useState('');
  const [isSignup, setIsSignup] = useState(false); // State for toggling between login and signup
  const [showPassword, setShowPassword] = useState(false); // State for password visibility
  const navigate = useNavigate();

  const togglePasswordVisibility = () => {
    setShowPassword((prev) => !prev);
  };

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const validatePassword = (password) => {
    const passwordRegex = /^(?=.*[A-Z]).{8,}$/;
    return passwordRegex.test(password);
  };

  const onSubmit = async (e) => {
    e.preventDefault();

    if (!validatePassword(formData.password)) {
      setPasswordError('Password must be at least 8 characters long and include at least one capital letter.');
      return;
    } else {
      setPasswordError('');
    }

    if (!isSignup) {
      try {
        const responseData = await adminLogin(formData);

        console.log('Login Response:', responseData); // Log the response

        if (responseData.token && responseData.adminId) {
          localStorage.setItem('admin_token', responseData.token);
          localStorage.setItem('admin_userId', responseData.adminId);
          navigate('/admin/dashboard');
          window.location.reload();
        } else {
          console.error('No adminId or token found in response');
        }
      } catch (error) {
        console.error('Frontend Error:', error);
        toast.error(error.response?.data?.errors || 'An error occurred. Please try again.');
      }
    } else {
      // Handle sign-up logic here
      console.log('Sign Up Data:', formData);
      toast.success('Sign Up successful! Proceed to login.');
      setIsSignup(false); // Return to login after successful sign-up
    }
  };

  return (
    <div className="login-container">
      <div className="login-box">
        <h1>{isSignup ? 'Sign Up' : 'Admin Login'}</h1>
        <form onSubmit={onSubmit}>
          <div>
            <label>Email:</label>
            <input type="email" name="email" value={formData.email} onChange={handleChange} required />
          </div>
          <div>
            <div className="password-container" style={{ position: 'relative' }}>
              <label>Password:</label>
              <input
                type={showPassword ? "text" : "password"}
                name="password"
                value={formData.password}
                onChange={handleChange}
                required
              />
              <span
                className="eye-icon"
                onClick={togglePasswordVisibility}
                style={{
                  cursor: 'pointer',
                  position: 'absolute',
                  right: '10px',
                  top: '60%',
                  transform: 'translateY(-50%)',
                }}
              >
                {showPassword ? <FaEyeSlash /> : <FaEye />}
              </span>
            </div>
            {passwordError && <p className="password-error">{passwordError}</p>}
          </div>
          <button type="submit">{isSignup ? 'Sign Up' : 'Login'}</button>
        </form>
        <p>
          {isSignup ? 'Already have an account?' : "Don't have an account?"}{' '}
          <span
            onClick={() => setIsSignup((prev) => !prev)}
            style={{ cursor: 'pointer', color: 'blue', textDecoration: 'underline' }}
          >
            {isSignup ? 'Login here' : 'Sign Up here'}
          </span>
        </p>
      </div>
    </div>
  );
};

export default LoginSignup;
