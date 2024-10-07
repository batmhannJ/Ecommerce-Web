import React, { useState, useContext, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { ShopContext } from "../../Context/ShopContext";
import { toast } from "react-toastify";
import "./SearchBar.css";

const SearchBar = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const navigate = useNavigate();
  const { all_product } = useContext(ShopContext);
  const [filteredProducts, setFilteredProducts] = useState([]);

  useEffect(() => {
    if (searchTerm.trim()) {
      const filtered = all_product.filter((product) =>
        product.name.toLowerCase().includes(searchTerm.toLowerCase())
      );
      setFilteredProducts(filtered);
    } else {
      setFilteredProducts([]);
    }
  }, [searchTerm, all_product]);

  useEffect(() => {
    if (filteredProducts.length > 0) {
      navigate("/search-results", { state: { filteredProducts } });
    } else if (searchTerm.trim()) {
    }
  }, [filteredProducts, navigate, searchTerm]);

  return (
    <div className="search-bar">
      <form style={{ width: "100%", display: "flex" }}>
        <input
          type="text"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          placeholder="Search for products..."
        />
      </form>
    </div>
  );
};

export default SearchBar;
