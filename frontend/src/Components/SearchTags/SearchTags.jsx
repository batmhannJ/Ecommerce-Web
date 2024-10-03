// SearchTags.js
import React, { useState, useContext } from "react";
import { useNavigate } from "react-router-dom";
import { ShopContext } from "../../Context/ShopContext";
import { toast } from "react-toastify";
import "./SearchTags.css";

const SearchTags = () => {
  const [selectedTags, setSelectedTags] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const navigate = useNavigate();
  const { all_product } = useContext(ShopContext);

  const handleTagClick = (tag) => {
    if (selectedTags.includes(tag)) {
      setSelectedTags(selectedTags.filter((t) => t !== tag));
    } else {
      setSelectedTags([tag]);
      handleSearchTag(tag);
    }
  };

  const handleSearchTag = (tag) => {
    const filteredProducts = all_product.filter(
      (product) =>
        product.name.toLowerCase().includes(tag.toLowerCase()) ||
        product.tags.some((t) => t.toLowerCase().includes(tag.toLowerCase()))
    );
    if (filteredProducts.length > 0) {
      navigate("/search-results", { state: { filteredProducts } });
    } else {
      toast.info("No products found", {
        position: "bottom-left",
      });
    }
  };

  const handleFilter = () => {
    const filteredProducts = all_product.filter((product) =>
      selectedTags.some((tag) => product.tags.includes(tag))
    );
    navigate("/search-results", { state: { filteredProducts } });
  };

  const handleSearch = (e) => {
    setSearchTerm(e.target.value);
  };

  const tags = all_product
    .reduce((acc, product) => {
      return [...acc, ...product.tags];
    }, [])
    .join(",")
    .split(",")
    .filter((tag, index, self) => self.indexOf(tag) === index);

  const randomTags = tags.sort(() => Math.random() - 0.5).slice(0, 10);

  const filteredTags = tags.filter((tag) =>
    tag.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const displayedTags = [
    ...selectedTags,
    ...filteredTags.filter((tag) => !selectedTags.includes(tag)),
  ].slice(0, 10);

  return (
    <div className="search-tags">
      <input
        type="text"
        value={searchTerm}
        onChange={handleSearch}
        placeholder="Search tags..."
      />
      <div className="tag-list">
        {displayedTags.map((tag, index) => (
          <button
            key={index}
            className={selectedTags.includes(tag) ? "selected" : ""}
            onClick={() => handleTagClick(tag)}
          >
            {tag}
          </button>
        ))}
      </div>
    </div>
  );
};

export default SearchTags;
