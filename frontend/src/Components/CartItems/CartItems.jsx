import React, { useContext, useEffect, useState } from "react";
import "./CartItems.css";
import { ShopContext } from "../../Context/ShopContext";
import { useNavigate } from "react-router-dom";
import remove_icon from "../Assets/remove_icon.png";
import { toast } from "react-toastify";
import axios from "axios";

const MAIN_OFFICE_COORDINATES = {
  latitude: 14.628488,
  longitude: 121.033420,
};

export const CartItems = () => {
  const {
    getTotalCartAmount,
    all_product,
    cartItems,
    setCartItems, // Assuming there's a setCartItems function in context
    removeFromCart,
    updateQuantity,
  } = useContext(ShopContext);
  const navigate = useNavigate();
  const [deliveryFee, setDeliveryFee] = useState(0);
  const [data, setData] = useState({ street: '', city: '' });

  // Fetch cart from database on component mount
  useEffect(() => {
    const fetchCartFromDatabase = async () => {
      const userId = localStorage.getItem("userId");
      if (!userId) return;

      try {
        const response = await axios.get(`http://localhost:4000/api/cart/${userId}`);
        if (response.data && response.data.cartItems) {
          setCartItems(response.data.cartItems);  // Update local state with saved cart items
        }
      } catch (error) {
        console.error("Error fetching cart:", error);
      }
    };

    fetchCartFromDatabase();
  }, [setCartItems]);

// Function to save cart to the database
const saveCartToDatabase = async () => {
  const userId = localStorage.getItem('userId');
  if (!userId) {
    console.error('No user ID found in local storage. Cannot save cart.');
    return;
  }

  try {
    await axios.post('http://localhost:4000/api/cart', {
      userId,
      cartItems
    });
    console.log("Cart saved to database successfully.");
  } catch (error) {
    console.error("Error saving cart to database:", error);
  }
};


  const fetchCoordinates = async (address) => {
    const apiKey = process.env.REACT_APP_POSITION_STACK_API_KEY;
    const url = `http://api.positionstack.com/v1/forward?access_key=${apiKey}&query=${address}`;

    try {
      const response = await axios.get(url);
      console.log("Coordinates Response:", response.data);
      return {
        latitude: response.data.data[0]?.latitude,
        longitude: response.data.data[0]?.longitude,
      };
    } catch (error) {
      console.error("Error fetching coordinates:", error);
      toast.error("Error fetching coordinates.");
      return null;
    }
  };

  const calculateDeliveryFee = async () => {
    const customerAddress = `${data.street}, ${data.city}`;
    console.log("Customer Address:", customerAddress);
    const coordinates = await fetchCoordinates(customerAddress);

    if (coordinates) {
      const distance = getDistanceFromLatLonInKm(
        MAIN_OFFICE_COORDINATES.latitude,
        MAIN_OFFICE_COORDINATES.longitude,
        coordinates.latitude,
        coordinates.longitude
      );

      console.log("Distance calculated:", distance);

      const baseFee = 40;
      const feePerKm = 5;

      let totalFee = baseFee + feePerKm * Math.ceil(distance);
      const maxDeliveryFee = 200;
      totalFee = totalFee > maxDeliveryFee ? maxDeliveryFee : totalFee;

      console.log("Total Delivery Fee:", totalFee);
      setDeliveryFee(totalFee);
    }
  };

  const getDistanceFromLatLonInKm = (lat1, lon1, lat2, lon2) => {
    const R = 6371; // Radius of the Earth in km
    const dLat = degreesToRadians(lat2 - lat1);
    const dLon = degreesToRadians(lon2 - lon1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(degreesToRadians(lat1)) * Math.cos(degreesToRadians(lat2)) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c; // Distance in km
  };

  const degreesToRadians = (degrees) => {
    return degrees * (Math.PI / 180);
  };

  useEffect(() => {
    if (data.street && data.city) {
      console.log("Calculating delivery fee for:", data);
      calculateDeliveryFee();
    }
  }, [data.street, data.city]);

  const handleQuantityChange = (key, delta) => {
    const currentQuantity = cartItems[key]?.quantity || 0;

    if (currentQuantity + delta > 0) {
        updateQuantity(key, currentQuantity + delta);
        saveCartToDatabase(); // Save updated cart to database
    } else {
        // Remove from cart if quantity becomes zero
        removeFromCart(key);
        saveCartToDatabase(); // Save after removing
    }
};


const handleProceedToCheckout = async () => {
  if (Object.keys(cartItems).length === 0) {
    toast.error("Your cart is empty. Please add items before checking out.");
    return;
  }

  const token = localStorage.getItem("auth-token");
  const userId = localStorage.getItem("userId");

  if (token) {
    try {
      const itemDetails = Object.values(cartItems).map(item => {
        const product = all_product.find(prod => prod.id === item.productId);
        return product ? { 
          id: product.id, // Add the product ID here
          name: product.name, 
          size: item.selectedSize, 
          quantity: item.quantity, 
          adjustedPrice: item.adjustedPrice, // Assuming adjustedPrice is stored in cartItems
          price: product.price // Add the original price (if applicable)
        } : null;
      }).filter(detail => detail !== null);
      
      // Pass itemDetails, deliveryFee, and data to the order page
      navigate("/order", { 
        state: { 
          itemDetails, // Send all item details
          deliveryFee,
          address: `${data.street}, ${data.city}` // Include address information
        }
      });
    } catch (error) {
      console.error("Error preparing data for checkout:", error);
    }
  } else {
    toast.error("You are not logged in. Please log in to proceed to checkout.", { position: "top-left" });
    navigate("/login");
  }
};


    // Group items by productId and size
  const groupedCartItems = Object.values(cartItems).reduce((acc, item) => {
      const product = all_product.find(prod => prod.id === item.productId);
      if (product && item.quantity > 0) {
          const sizeKey = `${item.productId}_${item.selectedSize}`; // This assumes `selectedSize` is defined
          if (!acc[sizeKey]) {
              acc[sizeKey] = { product, size: item.selectedSize, quantity: 0, adjustedPrice: item.adjustedPrice };
          }
          acc[sizeKey].quantity += item.quantity; // Sum quantities for same product and size
      }
      return acc;
  }, {});
  
    // Convert grouped object to array for rendering
    const groupedItemsArray = Object.values(groupedCartItems);

    return (
      <div className="cartitems">
        <div className="cartitems-format-main">
          <p>Products</p>
          <p>Title</p>
          <p>Price</p>
          <p>Size</p>
          <p>Quantity</p>
          <p>Total</p>
          <p>Remove</p>
        </div>
        <hr />
        {groupedItemsArray.length > 0 ? (
          groupedItemsArray.map((groupedItem, index) => (
            <div key={`${groupedItem.product.id}_${groupedItem.size}`}>
              <div className="cartitems-format cartitems-format-main">
                <img
                  src={groupedItem.product.image || remove_icon}
                  alt="Product"
                  className="cartitem-product-icon"
                />
                <p>{groupedItem.product.name}</p>
                <p>₱{groupedItem.adjustedPrice}</p>
                <p>{groupedItem.size}</p>
                <div className="cartitems-quantity-controls">
                  <button
                    className="cartitems-quantity-button"
                    onClick={() => handleQuantityChange(groupedItem.product.id, groupedItem.selectedSize, -1)}
                  >
                    -
                  </button>
                  <button className="cartitems-quantity-button">
                    {groupedItem.quantity}
                  </button>
                  <button
                    className="cartitems-quantity-button"
                    onClick={() => handleQuantityChange(groupedItem.product.id, groupedItem.selectedSize, 1)}
                  >
                    +
                  </button>
                </div>
                <p>₱{groupedItem.adjustedPrice * groupedItem.quantity}</p>
                <img
                  className="cartitems-remove-icon"
                  src={remove_icon}
                  onClick={async () => {
                    const selectedSize = groupedItem.size; // Use groupedItem.size instead of selectedSize
                    console.log(`Key to remove: ${groupedItem.product.id}_${selectedSize}`); // Log the key to debug
                    await removeFromCart(groupedItem.product.id, selectedSize); // Ensure you're passing both parameters
                    await saveCartToDatabase();
                }}
                  alt="Remove"
                />
              </div>
              <hr />
            </div>
          ))
        ) : (
          <p>No products in the cart</p>
        )}
        <div className="cartitems-down">
          <div className="cartitems-total">
            <h1>Cart Totals</h1>
            <div>
              <div className="cartitems-total-item">
                <p>Subtotal</p>
                <p>₱{getTotalCartAmount()}</p>
              </div>
              <hr />
              <div className="cartitems-total-item">
                <h3>Total</h3>
                <h3>₱{getTotalCartAmount() + deliveryFee}</h3>
              </div>
            </div>
            <button onClick={handleProceedToCheckout}>PROCEED TO CHECKOUT</button>
          </div>
        </div>
      </div>
    );
  };

export default CartItems;
