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

// Function to export dashboard as PDF
const generatePDF = async () => {
  const jsPDF = (await import("jspdf")).default;
  const doc = new jsPDF({ orientation: "portrait", unit: "mm", format: "a4", putOnlyUsedFonts: true });

  // Constants for margins
  const margin = 25.4; // 1 inch in mm
  const pageWidth = doc.internal.pageSize.getWidth();
  const pageHeight = doc.internal.pageSize.getHeight();
  const contentWidth = pageWidth - 2 * margin;

  // Title
  doc.setFontSize(20);
  doc.setFont("helvetica", "bold");
  const title = "Sales Report";
  const titleWidth = doc.getTextWidth(title);
  const titleX = (pageWidth - titleWidth) / 2; // Centering the title
  doc.text(title, titleX, margin); // Use margin for Y-coordinate

  // Add a line below the title
  doc.line(margin, margin + 5, pageWidth - margin, margin + 5);


  // Initial Y-coordinate for text entries
  let currentY = margin + 15;


  // Total Revenue
  doc.setFontSize(12);
  doc.setFont("helvetica", "bold");
  doc.text("Total Revenue: ", margin, currentY); // Label
  doc.setFont("helvetica", "normal");
  // Combine the label and value into one string
  doc.text(`\u20B1${totalRevenue}`, margin + 30, currentY);
  currentY -= 10; // Small increment for spacing

  // Average Order Value  
  doc.setFontSize(12);
  doc.setFont("helvetica", "bold");
  doc.text("Average Order Value", margin, margin + 35);
  doc.setFont("helvetica", "normal");
  doc.text(`₱${salesData.avgOrderValue.toFixed(2)}`, margin, margin + 45);

  // Most Produced Product
  doc.setFontSize(12); // Change to smaller size
  doc.setFont("helvetica", "bold");
  doc.text("Most Produced Product", margin, margin + 55);
  doc.setFont("helvetica", "normal");
  doc.text(`${salesData.mostProducedProduct || 'N/A'}`, margin, margin + 65);

  // Add a line
  doc.line(margin, margin + 70, pageWidth - margin, margin + 70);

  // Sales by Category
  doc.setFontSize(12);
  doc.setFont("helvetica", "bold");
  doc.text("Sales by Category:", margin, margin + 75);
  let categoryY = margin + 85;
  salesByCategoryData.forEach((item) => {
    doc.setFont("helvetica", "normal");
    doc.text(`${item.category}: ₱${item.totalSales}`, margin, categoryY);
    categoryY += 10;
  });

  // Add a line
  doc.line(margin, categoryY, pageWidth - margin, categoryY);
  categoryY += 5;

  // Sales by Product
  doc.setFontSize(12);
  doc.setFont("helvetica", "bold");
  doc.text("Sales by Product:", margin, categoryY);
  categoryY += 10;
  salesByProductData.forEach((item) => {
    doc.setFont("helvetica", "normal");
    doc.text(`${item.product}: ₱${item.totalSales}`, margin, categoryY);
    categoryY += 10;
  });

  // Add a line
  doc.line(margin, categoryY, pageWidth - margin, categoryY);
  categoryY += 5;

  // Sales Growth Rate
  doc.setFontSize(12);
  doc.setFont("helvetica", "bold");
  doc.text("Sales Growth Rate", margin, categoryY);
  categoryY += 10;

  // Add a line
  doc.line(10, categoryY, 200, categoryY);
  categoryY += 5;

  // Top Purchases Product
  doc.setFontSize(16);
  doc.setFont("helvetica", "bold");
  doc.text("Top Purchases Product:", 10, categoryY);
  categoryY += 10;
  topPurchasesProductData.forEach((item) => {
    doc.setFont("helvetica", "normal");
    doc.text(`${item.product}: ${item.totalPurchases}`, 10, categoryY);
    categoryY += 10;
  });

  // Save the PDF
  doc.save("dashboard_metrics.pdf");
};



  return (
    <div class="dashboard-container">
    <div className='dashboard'>
        <h1 id="yourElement">Dashboard</h1>

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

                <div className='chart-container'>
            {/* Sales Growth Rate Graph */}
            <div className='chart1'>
                <h3>Sales Growth Rate</h3>
                <Line data={salesGrowthRate} />
            </div>

            {/* Sales by Category Graph */}
            <div className='chart3'>
                <h3>Sales by Category</h3>
                <Pie data={salesByCategory} />
            </div>
        </div>

        {/* Sales by Product Graph */}
        <div className='chart2'>
            <h3>Sales by Product</h3>
            <Bar data={salesByProduct} />
        </div>
                      {/* Export Button */}
      <button onClick={generatePDF}>Export to PDF</button>
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
