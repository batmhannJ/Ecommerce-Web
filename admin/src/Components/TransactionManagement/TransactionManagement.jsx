import React, { useState, useEffect } from "react";
import axios from "axios";
import { Table } from "react-bootstrap"; // Using Bootstrap Table

export const TransactionManagement = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await axios.get(
          "http://localhost:4000/api/admin/getPaidItems"
        );
        setData(response.data);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  if (loading) {
    return <p>Loading...</p>;
  }

  if (error) {
    return <p>Error: {error}</p>;
  }

  return (
    <div className="transaction-grid">
      <h2>Transaction Management</h2>
      <Table striped bordered hover>
        <thead>
          <tr>
            <th>Buyer</th>
            <th>Total Price (PHP)</th>
            <th>Items</th>
            <th>Email</th>
          </tr>
        </thead>
        <tbody>
          {data.map((transaction) => (
            <tr key={transaction._id}>
              <td>
                {transaction.buyer.firstName} {transaction.buyer.lastName}
              </td>
              <td>{transaction.totalAmount.value}</td>
              <td>
                {transaction.items.map((item) => (
                  <p key={item._id}>{item.name} (x{item.quantity})</p>
                ))}
              </td>
              <td>{transaction.buyer.contact.email}</td>
            </tr>
          ))}
        </tbody>
      </Table>
    </div>
  );
};

export default TransactionManagement;