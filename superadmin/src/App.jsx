import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import LoginSignup from './Components/LoginSignUp/LoginSignup';
import AdminManagement from './Components/UserManagement/UserManagement';
import Dashboard from './Components/Dashboard/Dashboard';
import Admin from './Pages/Admin/Admin';
import Navbar from './Components/Navbar/Navbar';
import Verify from './Components/Verify';
import AccountSettings from './Components/AdminProfile/AccountSettings';

const App = () => {
  const isAuthenticated = !!localStorage.getItem('admin_token');

  return (
    <Routes>
      <Route path="/login" element={!isAuthenticated ? <LoginSignup /> : <Navigate to="/superadmin/usermanagement" />} />
      <Route
        path="/superadmin/*"
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
      <Route path="/superadmin/accountsettings" element={<AccountSettings />} />
    </Routes>
  );
};

export default App;
