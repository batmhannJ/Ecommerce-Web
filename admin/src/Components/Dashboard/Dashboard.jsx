import React, { useEffect, useState } from 'react';
import './Dashboard.css';
import { Bar, Pie, Line } from 'react-chartjs-2';
import Chart from 'chart.js/auto';

export const Dashboard = () => {
  const [totalRevenue, setTotalRevenue] = useState(0);
  const [salesData, setSalesData] = useState({
    avgOrderValue: 0,
    mostProducedProduct: '',
  });

  const [salesByCategoryData, setSalesByCategoryData] = useState([]);
  const [salesByProductData, setSalesByProductData] = useState([]);
  const [salesGrowthRateData, setSalesGrowthRateData] = useState([]);
  const [topPurchasesProductData, setTopPurchasesProductData] = useState([]);

  useEffect(() => {
    const fetchTotalRevenue = async () => {
      try {
        // Fetch from the cleaned-up backend route
        const response = await fetch('http://localhost:4000/api/transactions/totalAmount');

        console.log('Response status:', response.status);

        if (!response.ok) {
          throw new Error(`Network response was not ok, status: ${response.status}`);
        }

        const data = await response.json();
        console.log('Total revenue data:', data);
        setTotalRevenue(data);
      } catch (error) {
        console.error('Error fetching total revenue:', error);
      }
    };

    fetchTotalRevenue();
  }, []);


  useEffect(() => {
    const fetchAverageOrderValue = async () => {
      try {
        const response = await fetch('http://localhost:4000/api/transactions/averageOrderValue');
        console.log('AOV Response status:', response.status);
  
        if (!response.ok) {
          throw new Error(`Network response was not ok, status: ${response.status}`);
        }
  
        const data = await response.json();
        console.log('Average Order Value data:', data);
        setSalesData(prevData => ({
          ...prevData,
          avgOrderValue: data,
        }));
      } catch (error) {
        console.error('Error fetching average order value:', error);
      }
    };
  
    fetchAverageOrderValue();
  }, []);

  useEffect(() => {
    const fetchMostProducedProduct = async () => {
      try {
        const response = await fetch('http://localhost:4000/api/transactions/mostProducedProduct');
        console.log('Most Produced Product Response status:', response.status);
  
        if (!response.ok) {
          throw new Error(`Network response was not ok, status: ${response.status}`);
        }
  
        const data = await response.json();
        console.log('Most Produced Product data:', data);
        setSalesData(prevData => ({
          ...prevData,
          mostProducedProduct: data,
        }));
      } catch (error) {
        console.error('Error fetching most produced product:', error);
      }
    };
  
    fetchMostProducedProduct();
  }, []);

  useEffect(() => {
    const fetchSalesByProduct = async () => {
      try {
        const response = await fetch('http://localhost:4000/api/transactions/salesByProduct');
        if (!response.ok) throw new Error(`Network response was not ok, status: ${response.status}`);
        const data = await response.json();
        console.log('Sales by Product Data:', data); // Log the data fetched from the backend
        setSalesByProductData(data);
      } catch (error) {
        console.error('Error fetching sales by product:', error);
      }
    };
  
    fetchSalesByProduct();
  }, []);
  
  useEffect(() => {
    const fetchSalesByCategory = async () => {
      try {
        const response = await fetch('http://localhost:4000/api/transactions/salesByCategory');
        if (!response.ok) throw new Error(`Network response was not ok, status: ${response.status}`);
        const data = await response.json();
        console.log('Fetched Sales by Category Data:', data); // Add this line for debugging
        setSalesByCategoryData(data);
      } catch (error) {
        console.error('Error fetching sales by category:', error);
      }
    };
  
    fetchSalesByCategory();
  }, []);  

  useEffect(() => {
    const fetchSalesGrowthRate = async () => {
      try {
        const response = await fetch('http://localhost:4000/api/transactions/salesGrowthRate');
        if (!response.ok) throw new Error(`Network response was not ok, status: ${response.status}`);
        const data = await response.json();
        console.log('Sales Growth Rate Data:', data);
        setSalesGrowthRateData(data);
      } catch (error) {
        console.error('Error fetching sales growth rate:', error);
      }
    };
  
    fetchSalesGrowthRate();
  }, []);  
  
  useEffect(() => {
    const fetchTopPurchasesProduct = async () => {
      try {
        const response = await fetch('http://localhost:4000/api/transactions/topPurchasesProduct');
        if (!response.ok) throw new Error(`Network response was not ok, status: ${response.status}`);
        const data = await response.json();
        console.log('Top Purchases Product Data:', data);
        
        // Check if data is an array and has items
        if (Array.isArray(data) && data.length) {
          setTopPurchasesProductData(data);
        } else {
          console.log('No data available for Top Purchases Product.');
        }
      } catch (error) {
        console.error('Error fetching top purchases product:', error);
      }
    };
  
    fetchTopPurchasesProduct();
  }, []);
  
  
  // Dummy data for graphs, replace with actual fetched data
  const salesByProduct = {
    labels: salesByProductData.length ? salesByProductData.map(item => item.product) : ['No data'],
    datasets: [
      {
        label: 'Sales by Product',
        data: salesByProductData.length ? salesByProductData.map(item => item.totalSales) : [0],
        backgroundColor: '#ff6384',
      },
    ],
  };
  

  const salesByCategory = {
    labels: salesByCategoryData.map(item => item.category),
    datasets: [
      {
        label: 'Sales by Category',
        data: salesByCategoryData.map(item => item.totalSales),
        backgroundColor: ['#ff6384', '#36a2eb', '#ffce56'],
      },
    ],
  };
  
  
  const salesGrowthRate = {
    labels: salesGrowthRateData.map(item => item.date),
    datasets: [
      {
        label: 'Sales Growth Rate',
        data: salesGrowthRateData.map(item => item.totalSales),
        fill: false,
        backgroundColor: 'rgba(75,192,192,0.4)',
        borderColor: 'rgba(75,192,192,1)',
      },
    ],
  };
  
  const topPurchasesProduct = {
    labels: topPurchasesProductData.length ? topPurchasesProductData.map(item => item.product) : ['No data'],
    datasets: [
      {
        label: 'Top Purchases Product',
        data: topPurchasesProductData.length ? topPurchasesProductData.map(item => item.totalPurchases) : [0],
        backgroundColor: '#36a2eb',
      },
    ],
  };

  return (
    <div className='dashboard'>
        <h1>Dashboard</h1>

        <div className='dashboard-metrics'>
            {/* Revenue */}
            <div className='metric-box'>
                <h3>Total Revenue</h3>
                <p>₱{totalRevenue}</p>
            </div>

            {/* Average Order Value */}
            <div className='metric-box'>
                <h3>Average Order Value</h3>
                <p>
                    {salesData.avgOrderValue
                    ? `₱${salesData.avgOrderValue.toFixed(2)}`
                    : '₱0.00'}
                </p>
            </div>

            {/* Most Produced Product */}
            <div className='metric-box'>
                <h3>Most Produced Product</h3>
                <p>{salesData.mostProducedProduct || 'N/A'}</p>
            </div>
        </div>

        {/* Sales by Product Graph */}
        <div className='chart'>
            <h3>Sales by Product</h3>
            <Bar data={salesByProduct} />
        </div>

        {/* Container for bottom charts */}
        <div className='chart-container'>
            {/* Sales by Category Graph */}
            <div className='chart'>
                <h3>Sales by Category</h3>
                <Pie data={salesByCategory} />
            </div>

            {/* Sales Growth Rate Graph */}
            <div className='chart'>
                <h3>Sales Growth Rate</h3>
                <Line data={salesGrowthRate} />
            </div>
        </div>

        {/* Top Purchases Product Graph 
        <div className='chart'>
            <h3>Top Purchases Product</h3>
            <Bar data={topPurchasesProduct} />
        </div>*/}
    </div>
  );
};

export default Dashboard;
