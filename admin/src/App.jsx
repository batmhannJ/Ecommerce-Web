import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import LoginSignup from './Components/LoginSignUp/LoginSignup';
import Admin from './Pages/Admin/Admin';
import Navbar from './Components/Navbar/Navbar';
import Verify from './Components/Verify';

const App = () => {
  const isAuthenticated = !!localStorage.getItem('admin_token');

  return (
    <Routes>
      <Route path="/login" element={!isAuthenticated ? <LoginSignup /> : <Navigate to="/admin/listproducts" />} />
      <Route
        path="/admin/*"
        element={
          isAuthenticated ? (
            <>
              <Navbar />
              <Admin />
            </>
          ) : (
            <Navigate to="/login" />
          )
        }
      />
      <Route path="/verify" element={<Verify />} />
      <Route path="*" element={<Navigate to="/login" />} />
    </Routes>
  );
};

export default App;
