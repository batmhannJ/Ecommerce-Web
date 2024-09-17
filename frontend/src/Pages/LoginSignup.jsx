import React, { useState } from 'react';
import { toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import ReCAPTCHA from 'react-google-recaptcha';
import './CSS/LoginSignup.css';

const LoginSignup = () => {

  const [recaptchaToken, setRecaptchaToken] = useState(null); // State to store reCAPTCHA token

  // Handler for when reCAPTCHA is completed
  const onRecaptchaChange = (token) => {
    setRecaptchaToken(token);
  };
  
  const [state, setState] = useState("Login");
  const [formData, setFormData] = useState({
    username:"",
    password:"",
    email:"",
    otp:"",
    agreed: false,
    recaptchaToken: "" 
  });

  const [otpSent, setOtpSent] = useState(false);

  const changeHandler = (e) => {
    setFormData({...formData, [e.target.name]: e.target.value});
  };

  const checkboxHandler = () => {
    setFormData({...formData, agreed: !formData.agreed});
  };

   // Send OTP to user's email
   const sendOtp = async () => {
    if (!formData.email) {
      toast.error("Please enter your email address.");
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
        setOtpSent(true);  // Show the OTP input field
      } else {
        toast.error(data.errors);
      }
    } catch (error) {
      console.error("Error sending OTP:", error);
      toast.error("Failed to send OTP.");
    }
  };

  // Verify OTP and complete signup
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

  const login = async() => {
    if (!formData.agreed) {
      toast.error("Please agree to the terms of use & privacy policy.", {
        position: "top-left"
      });
      return;
    }

    if (!recaptchaToken) {
      toast.error("Please complete the CAPTCHA.", {
        position: "top-left"
      });
      return;
    }

    try {
      let responseData;
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
      if (!data.success) {
        toast.error(data.errors);
      } else {
        toast.success("Login successful!");
        localStorage.setItem('auth-token', data.token);
        window.location.replace("/");
      }
    } catch (error) {
      console.error("Login failed:", error);
      toast.error("An error occurred. Please try again.");
    }
  };

  const signup = async() => {
    if (!formData.agreed) {
      toast.error("Please agree to the terms of use & privacy policy.", {
        position: "top-left"
      });
      return;
    }

    console.log("Signup Function Executed", formData);
    let responseData;
    await fetch('http://localhost:4000/signup', {
      method:'POST',
      headers:{
        Accept:'application/json',
        'Content-Type':'application/json',
      },
      body: JSON.stringify(formData),
    }).then((response) => response.json()).then((data) => responseData=data);

    if (responseData.success) {
      localStorage.setItem('auth-token', responseData.token);
      window.location.replace("/");
    }
    else {
      toast.error(responseData.errors, {
        position: "top-left"
      });
    }
  };

  return (
    <div className='loginsignup'>
      <div className="loginsignup-container">
        <h1>{state}</h1>
        <div className="loginsignup-fields">
          {state === "Sign Up" ? <input name='username' value={formData.username} onChange={changeHandler} type="text" placeholder='Your Name' /> : null} 
          <input name='email' value={formData.email} onChange={changeHandler} type="email" placeholder='Email Address' />
          <input name='password' value={formData.password} onChange={changeHandler} type="password" placeholder='Password' />

          {otpSent && (
            <input name='otp' value={formData.otp} onChange={changeHandler} type="text" placeholder='Enter OTP' />
          )}
        </div>
        
        {state === "Login" && (
          <ReCAPTCHA
            sitekey="6LcCKEcqAAAAAF8ervh2kGqovSNLl1B9L02UZBhD"
            onChange={onRecaptchaChange}
          />
        )}

        <button onClick={() => { 
          state === "Login" 
            ? login()  // Only CAPTCHA verification for Login
            : otpSent ? verifyOtp() : sendOtp();  // OTP verification for Sign Up
        }}>Continue</button>
        {state === "Sign Up" ? 
          <p className="loginsignup-login">Already have an account? <span onClick={() => {setState("Login")}}>Login</span></p> 
          : <p className="loginsignup-login">Create an account? <span onClick={() => {setState("Sign Up")}}>Sign Up</span></p>}
        <div className="loginsignup-agree">
          <input type="checkbox" name='agreed' checked={formData.agreed} onChange={checkboxHandler} />
          <p>By continuing I agree to the terms of use & privacy policy</p>
        </div>
      </div>
    </div>
  );
}

export default LoginSignup;