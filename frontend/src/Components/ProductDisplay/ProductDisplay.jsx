import React, { useContext, useEffect, useState } from 'react';
import './ProductDisplay.css';
import { ShopContext } from '../../Context/ShopContext';
import { toast } from 'react-toastify';
import { useNavigate } from 'react-router-dom';

const ProductDisplay = (props) => {
  const { product } = props;
  const { addToCart } = useContext(ShopContext);
  const navigate = useNavigate();
  const [selectedSize, setSelectedSize] = useState('');
  const [adjustedPrice, setAdjustedPrice] = useState(product.new_price);
  const [currentStock, setCurrentStock] = useState(product.stock); // Default to total stock

  useEffect(() => {
    // Reset adjustedPrice and stock when product changes
    setAdjustedPrice(product.new_price);
    setSelectedSize(''); // Optionally reset size
    setCurrentStock(product.stock); // Reset to default total stock
  }, [product]);

  const handleSizeChange = (size) => {
    setSelectedSize(size);
    // Adjust price based on size
    setAdjustedPrice(product.new_price + 100 * (size === 'Small' ? 0 : size === 'Medium' ? 1 : size === 'Large' ? 2 : 3));
    
    // Check stock for selected size
    const stockForSelectedSize = product.size[size]?.stock || 0;
    setCurrentStock(stockForSelectedSize);
  };

  const handleAddToCart = async () => {
    const authToken = localStorage.getItem('auth-token');
  
    if (authToken) {
      if (!selectedSize) {
        toast.info('Please select a size before adding to cart.', {
          position: "bottom-left"
        });
        return;
      }
      try {
        await addToCart(product.id, selectedSize, adjustedPrice);
        toast.success('Product added to cart!', {
          position: "top-left"
        });
      } catch (error) {
        toast.error('An error occurred. Please try again.', {
          position: "top-left"
        });
      }
    } else {
      toast.error('You are not logged in. Please log in to add to cart.', {
        position: "top-left"
      });
      navigate('/login');
    }
  };

  return (
    <div className='productdisplay'>
      <div className="productdisplay-left">
        <div className="productdisplay-img-list">
          <img src={product.image} alt="" />
          <img src={product.image} alt="" />
          <img src={product.image} alt="" />
          <img src={product.image} alt="" />
        </div>
        <div className="productdisplay-img">
          <img className='productdisplay-main-img' src={product.image} alt="" />
        </div>
      </div>
      <div className="productdisplay-right">
        <h1>{product.name}</h1>
        <div className="productdisplay-right-prices">
          <div className="productdisplay-right-price-old">₱{product.old_price}</div>
          <div className="productdisplay-right-price-new">₱{adjustedPrice}</div>
        </div>
        <div className="productdisplay-stock">
          <div>No. of Stock: {currentStock}</div> {/* Display current stock based on size */}
        </div>
        <div className="productdisplay-right-size">
          <h1>Select Size</h1>
          <div className="productdisplay-right-sizes">
            {['Small', 'Medium', 'Large', 'XL'].map(size => (
              <div 
                key={size} 
                onClick={() => handleSizeChange(size)} 
                className={`size-option ${selectedSize === size ? 'selected' : ''}`}
              >
                {size}
              </div>
            ))}
          </div>
        </div>
        <button onClick={handleAddToCart}>ADD TO CART</button>
        <p className="productdisplay-right-category"><span>Category: </span>{product.category.toUpperCase()}</p>
        <p className="productdisplay-right-category"><span>Tags: </span>Modern, Latest</p>
      </div>
    </div>
  );
}

export default ProductDisplay;
