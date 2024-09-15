import React, { useContext, useEffect, useState } from "react";
import { ShopContext } from "../../Context/ShopContext";
import "./PlaceOrder.css";
import { toast } from "react-toastify";
import { useNavigate, useLocation } from "react-router-dom";  // useLocation for URL
import axios from "axios";

const generateReferenceNumber = () => {
  return `REF-${Date.now()}-${Math.floor(Math.random() * 10000)}`;
};

export const PlaceOrder = () => {
  const { getTotalCartAmount, all_product, cartItems } = useContext(ShopContext);
  const token = localStorage.getItem("auth-token");
  const navigate = useNavigate();
  const location = useLocation();  // Use useLocation to get the URL

  const [transactionId, setTransactionId] = useState(null);
  
  const [data, setData] = useState({
    firstName: "",
    lastName: "",
    email: "",
    street: "",
    city: "",
    state: "",
    zipcode: "",
    country: "",
    phone: "",
  });

  const onChangeHandler = (event) => {
    const name = event.target.name;
    const value = event.target.value;
    setData((prevData) => ({ ...prevData, [name]: value }));
  };

  const handleProceedToCheckout = async () => {
    if (token) {
      const cartDetails = all_product
        .filter(
          (product) => cartItems[product.id] && cartItems[product.id].quantity > 0
        )
        .map((product) => ({
          name: product.name,
          price: cartItems[product.id].price,
          quantity: cartItems[product.id].quantity,
        }));

      const requestReferenceNumber = generateReferenceNumber();
      const mayaApiUrl = "https://pg-sandbox.paymaya.com/checkout/v1/checkouts";
  
      const secretKey = process.env.REACT_APP_CHECKOUT_PUBLIC_API_KEY;
      if (!secretKey) {
        toast.error("Missing API Key. Please check the environment configuration.");
        return;
      }
  
      const encodedKey = btoa(`${secretKey}:`);
      const headers = {
        "Content-Type": "application/json",
        Authorization: `Basic ${encodedKey}`,
      };
  
      const requestBody = {
        totalAmount: {
          value: getTotalCartAmount() + 50,
          currency: "PHP",
        },
        buyer: {
          firstName: data.firstName,
          lastName: data.lastName,
          contact: {
            email: data.email,
            phone: data.phone,
          },
        },
        items: cartDetails.map((item) => ({
          name: item.name,
          quantity: item.quantity,
          amount: {
            value: item.price,
          },
          totalAmount: {
            value: item.price * item.quantity,
          },
        })),
          redirectUrl: {
            success: `http://localhost:3000/myorders?orderId=${requestReferenceNumber}`,
            failure: `http://localhost:3000/myorders?orderId=${requestReferenceNumber}`,
            cancel: `http://localhost:3000/myorders?orderId=${requestReferenceNumber}`,
          },
        requestReferenceNumber,
      };
  
      try {
        console.log("Request Headers:", headers);
        console.log("Request Body:", requestBody);
  
        const response = await axios.post(mayaApiUrl, requestBody, { headers });
        if (response.data && response.data.redirectUrl) {
          console.log("Redirecting to PayMaya:", response.data.redirectUrl);
          window.location.href = response.data.redirectUrl;

          const cartDetails = requestBody.items;

// Calculate total quantity and amount
          const totalQuantity = cartDetails.reduce((sum, item) => sum + item.quantity, 0);
          const totalAmount = cartDetails.reduce((sum, item) => sum + item.totalAmount.value, 0);
          const itemNames = cartDetails.map(item => item.name).join(', ');
          
          const saveTransaction = async (transactionDetails) => {
            try {
              await axios.post('http://localhost:4000/api/transactions', transactionDetails);
              console.log("Transaction saved:", transactionDetails);
            } catch (error) {
              console.error("Error saving transaction:", error);
            }
          };
          
          saveTransaction({
            transactionId: requestReferenceNumber,  // Pass the requestReferenceNumber here instead
            date: new Date(),
            name: `${data.firstName} ${data.lastName}`,
            contact: data.phone,  // Adjusted contact format
            item: itemNames,      // Concatenated item names
            quantity: totalQuantity,
            amount: totalAmount,
            address: `${data.street} ${data.city} ${data.state} ${data.zipcode} ${data.country}`,
            status: 'Paid'
          });
          
        } else {
          console.error("Checkout Response Error:", response.data);
          toast.error("Checkout failed, please try again.");
        }
      } catch (error) {
        console.error("Error during Maya checkout:", error.response ? error.response.data : error);
        toast.error(`Checkout failed: ${error.message}`);
      }
    } else {
      toast.error("You are not logged in. Please log in to proceed to checkout.");
      navigate("/login");
    }
  };
  
  useEffect(() => {
    if (getTotalCartAmount() === 0) {
      navigate("/cart");
    }
  }, [navigate, getTotalCartAmount]);

  useEffect(() => {
    const searchParams = new URLSearchParams(location.search); // Get the query parameters from the URL
    const id = searchParams.get("orderId");  // Extract the 'orderId' parameter from the URL
    if (id) {
      console.log("Transaction ID from URL:", id);  // Ensure this logs correctly
      setTransactionId(id); // Set the extracted id in state
    } else {
      console.error("No Transaction ID found in URL");
    }
  }, [location]);
  

  return (
    <form onSubmit={(e) => {e.preventDefault(); handleProceedToCheckout();}} className="place-order">
      <div className="place-order-left">
        <p className="title">Delivery Information</p>
        <div className="multi-fields">
          <input
            required
            name="firstName"
            onChange={onChangeHandler}
            value={data.firstName}
            type="text"
            placeholder="First Name"
          />
          <input
            required
            name="lastName"
            onChange={onChangeHandler}
            value={data.lastName}
            type="text"
            placeholder="Last Name"
          />
        </div>
        <input
          required
          name="email"
          onChange={onChangeHandler}
          value={data.email}
          type="email"
          placeholder="Email Address"
        />
        <input
          required
          name="street"
          onChange={onChangeHandler}
          value={data.street}
          type="text"
          placeholder="Street"
        />
        <div className="multi-fields">
          <input
            required
            name="city"
            onChange={onChangeHandler}
            value={data.city}
            type="text"
            placeholder="City"
          />
          <input
            required
            name="state"
            onChange={onChangeHandler}
            value={data.state}
            type="text"
            placeholder="State"
          />
        </div>
        <div className="multi-fields">
          <input
            required
            name="zipcode"
            onChange={onChangeHandler}
            value={data.zipcode}
            type="text"
            placeholder="Zip Code"
          />
          <input
            required
            name="country"
            onChange={onChangeHandler}
            value={data.country}
            type="text"
            placeholder="Country"
          />
        </div>
        <input
          required
          name="phone"
          onChange={onChangeHandler}
          value={data.phone}
          type="text"
          placeholder="Phone"
        />
      </div>
      <div className="place-order-right">
        <div className="cartitems-total">
          <h1>Cart Totals</h1>
          <div>
            <div className="cartitems-total-item">
              <p>Subtotal</p>
              <p>₱{getTotalCartAmount()}</p>
            </div>
            <hr />
            <div className="cartitems-total-item">
              <p>Delivery Fee</p>
              <p>₱{getTotalCartAmount() === 0 ? 0 : 50}</p>
            </div>
            <hr />
            <div className="cartitems-total-item">
              <h3>Total</h3>
              <h3>
                ₱{getTotalCartAmount() === 0 ? 0 : getTotalCartAmount() + 50}
              </h3>
            </div>
          </div>
          <button type="submit">PROCEED TO PAYMENT</button>
        </div>
      </div>
    </form>
  );
};

export default PlaceOrder;
