import React from 'react';
import './Admin.css';
import { Sidebar } from '../../Components/Sidebar/Sidebar';
import { Routes, Route } from 'react-router-dom';
import ListProduct from '../../Components/ListProduct/ListProduct';
import Orders from '../../Components/Orders/Orders';
import UserManagement from '../../Components/UserManagement/UserManagement';
import TransactionManagement from '../../Components/TransactionManagement/TransactionManagement';

const Admin = () => {
  return (
    <div className="admin">
      <Sidebar />
      <div className="admin-content">
        <Routes>
          <Route path="listproduct" element={<ListProduct />} />
          <Route path="orderproduct" element={<Orders />} />
          <Route path="usermanagement" element={<UserManagement />} />
          <Route path="transactions" element={<TransactionManagement />} />
        </Routes>
      </div>
    </div>
  );
};

export default Admin;
