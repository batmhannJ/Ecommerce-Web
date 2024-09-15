import React, { useState, useEffect } from 'react';

const TransactionManagement = () => {
  const [transactions, setTransactions] = useState([]);

  useEffect(() => {
    fetch('http://localhost:4000/api/transactions')
      .then(response => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then(data => {
        console.log("Fetched Transactions:", data);
        setTransactions(data);
      })
      .catch(error => console.error('Error fetching transactions:', error));
  }, []);

  return (
    <div>
      <h1>Transaction Management</h1>
      <table>
        <thead>
          <tr>
            <th>Date</th>
            <th>Name</th>
            <th>Contact</th>
            <th>Item</th>
            <th>Quantity</th>
            <th>Amount</th>
            <th>Address</th>
            <th>Transaction ID</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          {transactions.map(transaction => (
            <tr key={transaction.transactionId}>
              <td>{transaction.date}</td>
              <td>{transaction.name}</td>
              <td>{transaction.contact}</td>
              <td>{transaction.item}</td>
              <td>{transaction.quantity}</td>
              <td>{transaction.amount}</td>
              <td>{transaction.address}</td>
              <td>{transaction.transactionId}</td>
              <td>{transaction.status}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default TransactionManagement;
