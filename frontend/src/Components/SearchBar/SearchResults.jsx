import React from 'react';
import { useLocation } from 'react-router-dom';
import Item from './Item/Item';

const SearchResults = () => {
  const location = useLocation();
  const { filteredProducts } = location.state || { filteredProducts: [] };

  return (
    <div className="search-results">
      {filteredProducts.length ? (
        filteredProducts.map((product, index) => (
          <Item
            key={index}
            id={product.id}
            name={product.name}
            image={product.image}
            new_price={product.new_price}
            old_price={product.old_price}
          />
        ))
      ) : (
        <p>No products found.</p>
      )}
    </div>
  );
};

export default SearchResults;