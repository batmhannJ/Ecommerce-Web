import React, { useState, useContext } from "react";
import { useNavigate } from "react-router-dom";
import { ShopContext } from "../../Context/ShopContext";
import { toast } from "react-toastify";
import "./SearchBar.css";

const SearchBar = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const navigate = useNavigate();
  const { all_product } = useContext(ShopContext);

  const handleSearch = (e) => {
    e.preventDefault();
    if (searchTerm.trim()) {
      const foundProduct = all_product.find((product) =>
        product.name.toLowerCase().includes(searchTerm.toLowerCase())
      );
      if (foundProduct) {
        navigate(`/product/${foundProduct.id}`);
      } else {
        toast.info("No products found", {
          position: "bottom-left",
        });
      }
    }
  };

  return (
    <div className="search-bar">
      <form onSubmit={handleSearch} style={{ width: "100%", display: "flex" }}>
        <input
          type="text"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          placeholder="Search for products..."
        />
        <button type="submit">Search</button>
      </form>
    </div>
  );
};

export default SearchBar;
