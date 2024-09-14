import React, { useEffect, useState, useCallback } from "react";
import "./MyOrders.css";
import parcel_icon from "../../Components/Assets/parcel_icon.png";
import axios from "axios";
import { useParams } from "react-router-dom";

const MyOrders = () => {
  const { rrn } = useParams(); // Destructure rrn directly from useParams
  const [data, setData] = useState(null); // Initialize with null for better loading state handling
  const [loading, setLoading] = useState(true); // Track loading state
  const [error, setError] = useState(null); // Track any errors

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await axios.get(
          `http://localhost:4000/api/ordered-items/getOrderedItemsById/${rrn}`
        );
        setData(response.data);
        setLoading(false);
      } catch (err) {
        setError(err.message);
        setLoading(false);
      }
    };

    fetchData();
  }, [rrn]); // Dependency array to refetch data when rrn changes

  if (loading) {
    return <div>Loading...</div>; // Display loading message while data is being fetched
  }

  if (error) {
    return <div>Error: {error}</div>; // Display error message if there’s an error
  }

  return (
    <div className="my-orders">
      <h2>My Orders</h2>
      <div className="container">
        {/* Render the data here */}
        {data ? (
          <pre>{JSON.stringify(data, null, 2)}</pre> // Display data as JSON for debugging
        ) : (
          <p>No data available</p>
        )}
      </div>
    </div>
  );
};

export default MyOrders;
