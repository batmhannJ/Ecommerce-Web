import React, { useEffect, useState, useCallback } from "react";
import "./MyOrders.css";
import parcel_icon from "../../Components/Assets/parcel_icon.png";

const MyOrders = () => {
  const token = localStorage.getItem("auth-token");
  const [data, setData] = useState([]);

  const fetchOrders = useCallback(async () => {
    try {
      const response = await fetch(
        "http://localhost:3000/api/order/userorders",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify({}),
        }
      );

      if (!response.ok) {
        throw new Error("Failed to fetch orders");
      }
      const result = await response.json();
      const successfulOrders = result.data.filter(
        (order) => order.payment || order.status === "Paid"
      );

      setData(successfulOrders);
      console.log(successfulOrders);
    } catch (error) {
      console.error("Error fetching orders:", error);
    }
  }, [token]);

  useEffect(() => {
    if (token) {
      fetchOrders();
    }
  }, [token, fetchOrders]);

  return (
    <div className="my-orders">
      <h2>My Orders</h2>
      <div className="container">
        {data.map((order, index) => (
          <div key={index} className="my-orders-order">
            <img src={parcel_icon} alt="Parcel Icon" />
            <p>
              {order.items.map((item, idx) =>
                idx === order.items.length - 1
                  ? item.name + " x " + item.quantity
                  : item.name + " x " + item.quantity + ", "
              )}
            </p>
            <p>₱{order.amount}.00</p>
            <p>Items: {order.items.length}</p>
            <p>
              <span>&#x25cf;</span> <b>{order.status}</b>
            </p>
            <button onClick={fetchOrders}>Track Orders</button>
          </div>
        ))}
      </div>
    </div>
  );
};

export default MyOrders;
