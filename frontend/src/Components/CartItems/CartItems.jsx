import React, { useContext, useEffect, useState } from "react";
import "./CartItems.css";
import { ShopContext } from "../../Context/ShopContext";
import { useNavigate } from "react-router-dom";
import remove_icon from "../Assets/remove_icon.png";
import { toast } from "react-toastify";
import axios from "axios";

const MAIN_OFFICE_COORDINATES = {
  latitude: 14.628488,
  longitude: 121.033420
};

export const CartItems = () => {
  const {
    getTotalCartAmount,
    all_product,
    cartItems,
    removeFromCart,
    updateQuantity,
  } = useContext(ShopContext);
  const navigate = useNavigate();
  const [deliveryFee, setDeliveryFee] = useState(0);
  const [data, setData] = useState({ street: '', city: '' }); 

  /*useEffect(() => {
    const fetchUserDetails = async () => {
      const userId = localStorage.getItem("userId");
      if (!userId) {
        toast.error("No user logged in.");
        return;
      }
    
      try {
        const response = await axios.get(`http://localhost:4000/api/users/${userId}`);
        if (response.data) {
          setData({ street: response.data.address.street, city: response.data.address.city });
        }
      } catch (error) {
        console.error("Error fetching user details:", error);
        toast.error(`Error fetching user details: ${error.response?.data?.message || error.message}`);
      }
    };
    
  
    fetchUserDetails();
  // }, []); // No dependencies to fetch once on mount*/
  

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

      let totalFee = baseFee + (feePerKm * Math.ceil(distance));
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

  const handleQuantityChange = (id, delta) => {
    const currentQuantity = cartItems[id]?.quantity || 0;
    if (currentQuantity + delta >= 0) {
      updateQuantity(id, currentQuantity + delta);
    }
  };

  const handleProceedToCheckout = () => {
    const token = localStorage.getItem("auth-token");
    if (token) {
      navigate("/order");
    } else {
      toast.error(
        "You are not logged in. Please log in to proceed to checkout.",
        {
          position: "top-left",
        }
      );
      navigate("/login");
    }
  };

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
      {all_product && all_product.length > 0 ? (
        all_product.map((product) => {
          return Object.keys(cartItems).map((key) => {
            const [itemId, size] = key.split("_");
            if (parseInt(itemId) === product.id && cartItems[key].quantity > 0) {
              return (
                <div key={key}>
                  <div className="cartitems-format cartitems-format-main">
                    <img
                      src={product.image || remove_icon}
                      alt="Product Image"
                      className="cartitem-product-icon"
                    />
                    <p>{product.name}</p>
                    <p>₱{cartItems[key].price}</p>
                    <p>{size}</p>
                    <div className="cartitems-quantity-controls">
                      <button
                        className="cartitems-quantity-button"
                        onClick={() => handleQuantityChange(key, -1)}
                      >
                        -
                      </button>
                      <button className="cartitems-quantity-button">
                        {cartItems[key].quantity}
                      </button>
                      <button
                        className="cartitems-quantity-button"
                        onClick={() => handleQuantityChange(key, 1)}
                      >
                        +
                      </button>
                    </div>
                    <p>₱{cartItems[key].price * cartItems[key].quantity}</p>
                    <img
                      className="cartitems-remove-icon"
                      src={remove_icon}
                      onClick={() => removeFromCart(key)}
                      alt="Remove"
                    />
                  </div>
                  <hr />
                </div>
              );
            }
            return null;
          });
        })
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
            {/* 
<div className="cartitems-total-item">
  <p>Delivery Fee</p>
  <p>₱{deliveryFee}</p>
</div>

            <hr />*/}
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
