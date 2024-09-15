import React, { useEffect, useState, useCallback } from "react";
import "./MyOrders.css";
import parcel_icon from "../../Components/Assets/parcel_icon.png";
import axios from "axios";
import { useParams } from "react-router-dom";

const MyOrders = () => {
  const { rrn } = useParams();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await axios.get(
          `http://localhost:4000/api/ordered-items/getOrderedItemsById/${rrn}`
        );
        setData(response.data);
        setLoading(false);
      } catch (err) {
        if (err.response && err.response.status === 404) {
          const response = await axios.get(
            `http://localhost:4000/api/ordered-items/getPaidItems`
          );
          setData(response.data);
          setLoading(false);
        } else {
          setError("An unexpected error occurred.");
        }
        setLoading(false);
      }
    };

    fetchData();
  }, [rrn]);

  if (loading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>Error: {error}</div>;
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
