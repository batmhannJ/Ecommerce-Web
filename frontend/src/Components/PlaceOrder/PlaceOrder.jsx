import React, { useContext, useEffect, useState } from "react";
import { ShopContext } from "../../Context/ShopContext";
import "./PlaceOrder.css";
import { toast } from "react-toastify";
import { useNavigate } from "react-router-dom";
import { createCheckout } from "../Payment/services/checkout.ts"

export const PlaceOrder = () => {
  const { getTotalCartAmount, cartItems, prepareOrderItems } = useContext(ShopContext);
  const token = localStorage.getItem("auth-token");
  const navigate = useNavigate();

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

  const placeOrder = async (event) => {
    event.preventDefault();

    if (!token) {
      toast.error("Please login again.", {
        position: "top-left",
      });
      return;
    }

    try {
      const orderItems = await prepareOrderItems(cartItems);
      console.log('Order Items to be sent:', orderItems);

      const orderData = {
        address: data,
        items: orderItems,
        amount: getTotalCartAmount() + 50,
      };

      const response = await fetch('http://localhost:4000/api/order/place', {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(orderData),
      });

      const responseData = await response.json();

      if (responseData.success) {
        const checkoutResponse = await createCheckout(orderData, {
          firstName: data.firstName,
          lastName: data.lastName,
        });

        if (checkoutResponse.success) {
          const { session_url } = checkoutResponse;
          window.location.replace(session_url);
        } else {
          toast.error("Error creating Maya checkout session.", {
            position: "top-left",
          });
          console.error("Error:", checkoutResponse.error);
        }
      } else {
        toast.error("Error placing order", {
          position: "top-left",
        });
      }
    } catch (error) {
      toast.error("An error occurred. Please try again.", {
        position: "top-left",
      });
      console.error("Error placing order:", error);
    }
  };

  useEffect(() => {
    if (getTotalCartAmount() === 0) {
      navigate('/cart');
    }
  }, [navigate]);

  return (
    <form onSubmit={placeOrder} className="place-order">
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
              <h3>₱{getTotalCartAmount() === 0 ? 0 : getTotalCartAmount() + 50}</h3>
            </div>
          </div>
          <button type="submit">PROCEED TO PAYMENT</button>
        </div>
      </div>
    </form>
  );
};

export default PlaceOrder;