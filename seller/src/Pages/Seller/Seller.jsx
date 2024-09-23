import React from "react";
import "./Seller.css";
import { Sidebar } from "../../Components/Sidebar/Sidebar";
import { Routes, Route } from "react-router-dom";
import AddProduct from "../../Components/AddProduct/AddProduct";
import ListProduct from "../../Components/ListProduct/ListProduct";
import Orders from "../../Components/Orders/Orders";

const Seller = () => {
  return (
    <div className="admin">
      <Sidebar />
      <Routes>
        <Route path="addproduct" element={<AddProduct />} /> {/* Remove leading / */}
        <Route path="listproduct" element={<ListProduct />} /> {/* Remove leading / */}
        <Route path="orders" element={<Orders />} /> {/* Remove leading / */}
      </Routes>
    </div>
  );
};

export default Seller;
