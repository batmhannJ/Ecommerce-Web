import React, { useState } from 'react';
import { toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import { useUser } from '../Context/UserContext';  // Import User Context
import './CSS/LoginSignup.css';

const LoginSignup = () => {
  const { login: contextLogin } = useUser();  
  const [state, setState] = useState("Login");
  const [formData, setFormData] = useState({
    username: "",
    password: "",
    email: "",
    agreed: false
  });

  const changeHandler = (e) => {
    setFormData({...formData, [e.target.name]: e.target.value});
  };

  const checkboxHandler = () => {
    setFormData({...formData, agreed: !formData.agreed});
  };

  const login = async () => {
    if (!formData.agreed) {
      toast.error("Please agree to the terms of use & privacy policy.", {
        position: "top-left"
      });
      return;
    }

    console.log("Login Function Executed", formData);
    try {
      const response = await fetch('http://localhost:4000/login', {
        method: 'POST',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      });
      const responseData = await response.json();
      console.log('Response Data:', responseData); // Debugging

      if (responseData.success) {
        console.log('Logging in user:', responseData.userData); // Debugging
        console.log('Token:', responseData.token); // Debugging
        contextLogin(responseData.userData, responseData.token); // Update context
        window.location.replace("/"); // Redirect after login
      } else {
        toast.error(responseData.errors, {
          position: "top-left"
        });
      }
    } catch (error) {
      console.error('Login error:', error); // Handle fetch errors
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
        Accept:'application/form-data',
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
        </div>
        <button onClick={() => {state === "Login" ? login() : signup()}}>Continue</button>
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