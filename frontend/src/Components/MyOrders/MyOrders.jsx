import React, { useEffect, useState, useCallback } from 'react';
import { useLocation } from 'react-router-dom';
import './MyOrders.css';
import parcel_icon from '../../Components/Assets/parcel_icon.png';
import { useUser } from '../../Context/UserContext';


const MyOrders = () => {
  const { user } = useUser();
  const userId = user?.id;
 const token = localStorage.getItem("auth-token");
console.log("Token from localStorage:", token);

  const [data, setData] = useState([]);
  const [error, setError] = useState(null); // Define error state
  const location = useLocation();

  // Extract PayMaya transaction ID from URL params
  const getTransactionIdFromUrl = () => {
    const searchParams = new URLSearchParams(location.search);
    return searchParams.get("id");
  };

  const fetchOrders = useCallback(async () => {
    try {
      const transactionId = getTransactionIdFromUrl(); // Get the transaction ID
      console.log("Transaction ID:", transactionId);

      if (!userId) {
        throw new Error('UserId is missing in localStorage');
      }

      const response = await fetch('http://localhost:4000/api/order/userorders', { // Adjusted endpoint
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ id: userId, checkoutId: transactionId }) // Ensure transactionId is passed
      });

      if (!response.ok) {
        throw new Error('Failed to fetch orders');
      }
      const result = await response.json();
      console.log('API Response:', result);

      if (result.success) {
        // Filter successful orders with 'Paid' status
        const successfulOrders = result.data.filter(order => order.payment || order.status === 'Paid');

        // Check if there are no 'Paid' orders
        if (successfulOrders.length === 0) {
          console.log("No orders with 'Paid' status found");
        }

        // Update state with filtered orders
        setData(successfulOrders);
      } else {
        throw new Error(result.message);
      }
    } catch (error) {
      setError(error.message); // Set error message
      console.error('Error fetching orders:', error);
    }
  }, [userId, token, location.search]); // Added location.search to dependencies

  useEffect(() => {
    if (token) {
      console.log('User ID from context:', user?.id); // Debug log
      fetchOrders();
    }
  }, [token, fetchOrders]);

  return (
    <div className='my-orders'>
      <p>Welcome back, {user?.id}!</p> {/* Handle case if user is null */}
      <h2>My Orders</h2>
      <div className="container">
        {error && <p>{error}</p>}
        {data.length > 0 ? (
          <ul>
            {data.map((order) => (
              <li key={order.id}>{order.details}</li>
            ))}
          </ul>
        ) : (
          <p>No orders found.</p>
        )}
        {data.map((order, index) => (
          <div key={index} className='my-orders-order'>
            <img src={parcel_icon} alt="Parcel Icon" />
            <p>{order.items.map((item, idx) => (
              idx === order.items.length - 1
                ? item.name + " x " + item.quantity
                : item.name + " x " + item.quantity + ", "
            ))}</p>
            <p>₱{order.amount}.00</p>
            <p>Items: {order.items.length}</p>
            <p><span>&#x25cf;</span> <b>{order.status}</b></p>
            <button onClick={fetchOrders}>Track Orders</button>
          </div>
        ))}
      </div>
    </div>
  );
};

export default MyOrders;
