import React, { useEffect } from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import ShopContextProvider from './Context/ShopContext';
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

// Import the functions from the package
import { regions, provincesByCode, cities, barangays } from 'select-philippines-address';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <ShopContextProvider>
    <App />
    <ToastContainer />
  </ShopContextProvider>
);

// Fetch regions, provinces, cities, and barangays
const fetchAddressDetails = async () => {
  try {
    // Fetch regions
    const regionList = await regions();
    console.log('Regions:', regionList);

    // Get the first region's code
    const regionCode = regionList[0]?.region_code;
    if (!regionCode) throw new Error('Region code not found');

    // Fetch provinces by region code
    const provinceList = await provincesByCode(regionCode);
    console.log('Provinces:', provinceList);

    // Get the first province's code
    const provinceCode = provinceList[0]?.province_code;
    if (!provinceCode) throw new Error('Province code not found');

    // Fetch cities by province code
    const cityList = await cities(provinceCode);
    console.log('Cities:', cityList);

    // Get the first city's code
    const cityCode = cityList[0]?.city_code;
    if (!cityCode) throw new Error('City code not found');

    // Fetch barangays by city code
    const barangayList = await barangays(cityCode);
    console.log('Barangays:', barangayList);

  } catch (error) {
    console.error('Error fetching address details:', error);
  }
};

// Trigger fetching of address details when the app loads
fetchAddressDetails();
