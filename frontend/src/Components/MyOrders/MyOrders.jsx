import React, { useState, useEffect } from "react";
import axios from "axios";
import { toast } from "react-toastify";
import "./MyOrders.css"; // Include your CSS here

const getUserIdFromToken = () => {
  const authToken = localStorage.getItem("auth-token");
  if (authToken) {
    const payload = JSON.parse(atob(authToken.split(".")[1]));
    return payload.user.id;
  }
  return null;
};

const updateTransactionStatus = async (transactionId, newStatus) => {
  try {
    const response = await fetch(
      `http://localhost:4000/api/transactions/updateTransactionStatus/${transactionId}`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ status: newStatus }),
      }
    );

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    console.log("Transaction updated:", data);
    return data;
  } catch (error) {
    console.error("Error updating transaction:", error);
    throw error;
  }
};

const MyOrders = () => {
  const [orders, setOrders] = useState([]);
  const [filteredOrders, setFilteredOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");
  const currentUrl = window.location.href;
  const url = new URL(currentUrl);
  const params = url.searchParams;
  const userId = getUserIdFromToken();
  const status = params.get("status");

  useEffect(() => {
    handleTransactionStatus(status);
  }, [status]);

  const handleTransactionStatus = (status) => {
    switch (status) {
      case "Failed":
        toast.warn("The transaction Failed.");
        break;
      case "Success":
        toast.success("The transaction has been processed successfully.");
        break;
      case "Cancelled":
        toast.info("The transaction has been cancelled.");
        break;
      default:
    }
  };

  if (params.toString() !== "") {
    const orderId = params.get("orderId");
    if (orderId && status === "success") {
      console.log("Order ID:", orderId);
      updateTransactionStatus(orderId, "Paid")
        .then((result) => {
          console.log("Transaction status updated:", result);
        })
        .catch((error) => {
          console.error("Failed to update transaction status:", error);
        });
    } else {
    }
  } else {
    console.log("No parameters in the URL");
  }

  // Fetch orders on mount
  useEffect(() => {
    const fetchOrders = async () => {
      try {
        const response = await axios.get(
          `http://localhost:4000/api/transactions/userTransactions/${userId}`
        );
        const fetchedOrders = Array.isArray(response.data) ? response.data : [];
        const filteredOrders = fetchedOrders.filter(
          (order) => order.status !== "pending"
        );
        setOrders(filteredOrders);
        setFilteredOrders(filteredOrders);
      } catch (error) {
        console.error("Error fetching orders:", error);
        toast.error("Error fetching orders.");
      } finally {
        setLoading(false);
      }
    };

    // Initial fetch
    fetchOrders();

    // Poll every 1 second
    const intervalId = setInterval(() => {
      fetchOrders();
    }, 1000);

    // Cleanup on component unmount
    return () => clearInterval(intervalId);
  }, [userId]);

  // Handle search input change
  const handleSearchChange = (e) => {
    const value = e.target.value;
    setSearchTerm(value);

    // Filter orders based on search term
    const filtered = orders.filter(
      (order) =>
        order.item.toLowerCase().includes(value.toLowerCase()) &&
        order.status !== "pending"
    );
    setFilteredOrders(filtered);
  };

  return (
    <div className="my-order-container">
      <h1>My Orders</h1>
      {loading ? (
        <p>Loading...</p>
      ) : (
        <table className="order-table">
          <thead>
            <tr>
              <th>Order ID</th>
              <th>Date</th>
              <th>Item</th>
              <th>Quantity</th>
              <th>Amount</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            {filteredOrders.length > 0 ? (
              filteredOrders.map((order) => (
                <tr key={order._id}>
                  <td>{order.transactionId}</td>
                  <td>{order.date}</td>
                  <td>{order.item}</td>
                  <td>{order.quantity}</td>
                  <td>{order.amount}</td>
                  <td>{order.status}</td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan="6">No orders found</td>
              </tr>
            )}
          </tbody>
        </table>
      )}
    </div>
  );
};

export default MyOrders;
