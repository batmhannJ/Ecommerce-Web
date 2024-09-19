import React, { useState } from 'react';
import { toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import ReCAPTCHA from 'react-google-recaptcha';
import './CSS/LoginSignup.css';

const LoginSignup = () => {
  const [recaptchaToken, setRecaptchaToken] = useState(null);
  const [forgotPasswordMode, setForgotPasswordMode] = useState(false);
  const [emailForReset, setEmailForReset] = useState("");
  const [otpSentForReset, setOtpSentForReset] = useState(false);
  const [resetPasswordForm, setResetPasswordForm] = useState({
    otp: '',
    newPassword: '',
    confirmPassword: ''
  });

  const [state, setState] = useState("Login");
  const [formData, setFormData] = useState({
    username: "",
    password: "",
    email: "",
    otp: "",
    newPassword: "",
    confirmPassword: "",
    agreed: false,
    recaptchaToken: "" 
  });

  const [otpSent, setOtpSent] = useState(false);

  // New state variables for error messages
  const [emailError, setEmailError] = useState("");
  const [passwordError, setPasswordError] = useState("");

  const changeHandler = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const checkboxHandler = () => {
    setFormData({ ...formData, agreed: !formData.agreed });
  };

  const sendOtp = async () => {
    if (!formData.email) {
      setEmailError("Please enter your email address.");
      return;
    }

    try {
      const response = await fetch('http://localhost:4000/send-otp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: formData.email }),
      });

      const data = await response.json();
      if (data.success) {
        toast.success("OTP sent to your email.");
        setOtpSent(true);
        setEmailError(""); // Clear any previous errors
      } else {
        setEmailError(data.errors || "Failed to send OTP.");
      }
    } catch (error) {
      console.error("Error sending OTP:", error);
      toast.error("Failed to send OTP.");
    }
  };

  const verifyOtp = async () => {
    if (!formData.otp) {
      toast.error("Please enter the OTP.");
      return;
    }

    try {
      const response = await fetch('http://localhost:4000/verify-otp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: formData.email,
          otp: formData.otp,
          username: formData.username,
          password: formData.password,
        }),
      });

      const data = await response.json();
      if (data.success) {
        toast.success("Signup successful!");
        localStorage.setItem('auth-token', data.token);
        window.location.replace("/"); 
      } else {
        toast.error(data.errors);
      }
    } catch (error) {
      console.error("Error verifying OTP:", error);
      toast.error("Failed to verify OTP.");
    }
  };

  const verifyOtpAndResetPassword = async () => {
    const { otp, newPassword, confirmPassword } = resetPasswordForm;

    if (!otp || !newPassword || !confirmPassword) {
      toast.error("Please fill in all fields.");
      return;
    }

    if (newPassword !== confirmPassword) {
      toast.error("Passwords do not match.");
      return;
    }

    try {
      const response = await fetch('http://localhost:4000/reset-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: emailForReset,
          otp,
          newPassword
        })
      });

      const data = await response.json();
      if (data.success) {
        toast.success("Password successfully changed!");
        localStorage.setItem('auth-token', data.token);
        window.location.replace("/"); 
      } else {
        toast.error(data.errors);
      }
    } catch (error) {
      console.error("Error resetting password:", error);
      toast.error("Failed to reset password.");
    }
  };

  const sendPasswordResetEmail = async () => {
    if (!emailForReset) {
      setEmailError("Please enter your email address.");
      return;
    }

    try {
      const response = await fetch('http://localhost:4000/forgot-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: emailForReset }),
      });

      const data = await response.json();
      if (data.success) {
        toast.success("OTP sent to your email.");
        setOtpSentForReset(true);
        setEmailError(""); // Clear any previous errors
      } else {
        setEmailError(data.errors || "Failed to send password reset email.");
      }
    } catch (error) {
      console.error("Error sending reset password email:", error);
      setEmailError("Failed to send password reset email.");
    }
  };

  const handleResetPasswordFormChange = (e) => {
    setResetPasswordForm({ ...resetPasswordForm, [e.target.name]: e.target.value });
  };

  const handleRecaptchaChange = (value) => {
    setRecaptchaToken(value);
  };

  const login = async () => {
    if (!formData.agreed) {
      toast.error("Please agree to the terms of use & privacy policy.");
      return;
    }

    if (!recaptchaToken) {
      toast.error("Please complete the CAPTCHA.");
      return;
    }

    try {
      const response = await fetch('http://localhost:4000/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: formData.email,
          password: formData.password,
          recaptchaToken: recaptchaToken
        })
      });

      const data = await response.json();
      if (data.success) {
        toast.success("Login successful!");
        localStorage.setItem('auth-token', data.token);
        window.location.replace("/"); 
      } else {
        if (data.errors.includes("email")) {
          setEmailError("Invalid email address.");
        }
        if (data.errors.includes("password")) {
          setPasswordError("Incorrect password.");
        }
        toast.error(data.errors);
      }
    } catch (error) {
      console.error("Login failed:", error);
      toast.error("An error occurred. Please try again.");
    }
  };

  const signup = async () => {
    if (!formData.agreed) {
      toast.error("Please agree to the terms of use & privacy policy.");
      return;
    }

    try {
      const response = await fetch('http://localhost:4000/signup', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData),
      });

      const data = await response.json();
      if (data.success) {
        localStorage.setItem('auth-token', data.token);
        window.location.replace("/"); 
      } else {
        toast.error(data.errors);
      }
    } catch (error) {
      console.error("Signup failed:", error);
      toast.error("An error occurred. Please try again.");
    }
  };

  return (
    <div className='loginsignup'>
      <div className="loginsignup-container">
        <h1>{forgotPasswordMode ? "Forgot Password" : state}</h1>
        {forgotPasswordMode ? (
          <div className="loginsignup-fields">
            {!otpSentForReset ? (
              <>
                <input
                  name='emailForReset'
                  value={emailForReset}
                  onChange={(e) => setEmailForReset(e.target.value)}
                  type="email"
                  placeholder='Email Address'
                />
                {emailError && <p className="error-message">{emailError}</p>}
                <button onClick={sendPasswordResetEmail}>Send OTP</button>
              </>
            ) : (
              <>
                <input
                  name='otp'
                  value={resetPasswordForm.otp}
                  onChange={handleResetPasswordFormChange}
                  type="text"
                  placeholder='Enter OTP'
                />
                <input
                  name='newPassword'
                  value={resetPasswordForm.newPassword}
                  onChange={handleResetPasswordFormChange}
                  type="password"
                  placeholder='New Password'
                />
                <input
                  name='confirmPassword'
                  value={resetPasswordForm.confirmPassword}
                  onChange={handleResetPasswordFormChange}
                  type="password"
                  placeholder='Confirm Password'
                />
                {passwordError && <p className="error-message">{passwordError}</p>}
                <button onClick={verifyOtpAndResetPassword}>Reset Password</button>
              </>
            )}
            <p onClick={() => setForgotPasswordMode(false)} className="back-to-login">
              Back to Login
            </p>
          </div>
        ) : (
          <>
            <div className="loginsignup-fields">
              {state === "Sign Up" ? 
                <input name='username' value={formData.username} onChange={changeHandler} type="text" placeholder='Your Name' /> 
                : null
              }
              <input
                name='email'
                value={formData.email}
                onChange={changeHandler}
                type="email"
                placeholder='Email Address'
              />
              {emailError && <p className="error-message">{emailError}</p>}
              <input
                name='password'
                value={formData.password}
                onChange={changeHandler}
                type="password"
                placeholder='Password'
              />
              {passwordError && <p className="error-message">{passwordError}</p>}
              {otpSent && (
                <input
                  name='otp'
                  value={formData.otp}
                  onChange={changeHandler}
                  type="text"
                  placeholder='Enter OTP'
                />
              )}
            </div>

            {state === "Login" && (
              <>
                <div className="recaptcha-container">
                  <ReCAPTCHA
                    sitekey="6LcCKEcqAAAAAF8ervh2kGqovSNLl1B9L02UZBhD"
                    onChange={handleRecaptchaChange}
                  />
                </div>
                <p className="forgot-password" onClick={() => setForgotPasswordMode(true)}>
                  Forgot Password?
                </p>
              </>
            )}

            <button onClick={() => { 
              state === "Login" 
                ? login()
                : otpSent ? verifyOtp() : sendOtp();
            }}>Continue</button>
            {state === "Sign Up" ? 
              <p className="loginsignup-login">Already have an account? <span onClick={() => setState("Login")}>Login</span></p> 
              : <p className="loginsignup-login">Create an account? <span onClick={() => setState("Sign Up")}>Sign Up</span></p>
            }
            <div className="loginsignup-agree">
              <input type="checkbox" name='agreed' checked={formData.agreed} onChange={checkboxHandler} />
              <p>By continuing I agree to the terms of use & privacy policy</p>
            </div>
          </>
        )}
      </div>
    </div>
  );
}

export default LoginSignup;
