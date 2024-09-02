import React, { useState } from "react";
import axios from "axios";
import { toast } from "react-toastify";
import "./SearchBar.css";

const UserSearchBar = ({ onSearch }) => {
  const [searchTerm, setSearchTerm] = useState("");

  const handleSearch = async (e) => {
    e.preventDefault();
    if (searchTerm.trim()) {
      try {
        const response = await axios.get(`http://localhost:4000/api/users/search?term=${searchTerm}`);
        onSearch(response.data);
      } catch (error) {
        toast.error("Error searching users.");
        console.error(error);
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
          placeholder="Search for users..."
        />
        <button type="submit">Search</button>
      </form>
    </div>
  );
};

export default UserSearchBar;
