import React, { useState, useEffect } from 'react';
import './Orders.css';
import { toast } from "react-toastify";
import parcel_icon from "../../assets/parcel_icon.png"

const Orders = () => {
  const [orders, setOrders] = useState([]);

  const fetchAllOrders = async () => {
    try {
      const response = await fetch('http://localhost:4000/api/order/list');
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      const data = await response.json();
      if (data.success) {
        setOrders(data.data);
        console.log(data.data);
      } else {
        toast.error("Error fetching orders");
      }
    } catch (error) {
      console.error('Error fetching orders:', error);
      toast.error("Error fetching orders");
    }
  };

  const statusHandler = async (event, orderId) => {
    try {
      const response = await fetch("http://localhost:4000/api/order/status", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          orderId,
          status: event.target.value,
        }),
      });
  
      if (!response.ok) {
        throw new Error("Failed to update status");
      }
  
      const responseData = await response.json();
  
      if (responseData.success) {
        await fetchAllOrders();
      }
    } catch (error) {
      console.error("Error updating status:", error);
    }
  };
  

  useEffect(() => {
    fetchAllOrders();
  }, []);

  return (
    <div className='order add'>
      <h3>Order Page</h3>
      <div className="order-list">
        {orders.map((order, index)=>(
          <div key={index} className='order-item'>
            <img src={parcel_icon} alt="" />
            <div>
              <p className='order-item-food'>
              {order.items.map((item, index)=>{
                if (index===order.items.length-1) {
                  return item.name + " x " + item.quantity
                }
                else {
                  return item.name + " x " + item.quantity +", "
                }
              })}
              </p>
              <p className="order-item-name">{order.address.firstName+" "+order.address.lastName}</p>
              <div className="order-item-address">
                <p>{order.address.street+","}</p>
                <p>{order.address.city+", "+order.address.state+", "+order.address.country+", "+order.address.zipcode}</p>
              </div>
              <p className='order-item-phone'>{order.address.phone}</p>
            </div>
            <p>Items : {order.items.length}</p>
            <p>₱{order.amount}</p>
            <select onChange={(event)=>statusHandler(event, order._id)} value={order.status}>
              <option value="Cart Processing">Cart Processing</option>
              <option value="Out for Delivery">Out for Delivery</option>
              <option value="Delivered">Delivered</option>
            </select>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Orders;
