import axios from 'axios';

const API_URL = 'http://localhost:4000/api/seller';

export const sellerSignup = async (data) => {
  const response = await axios.post(`${API_URL}/signup`, data);
  return response.data;
};

export const sellerLogin = async (loginData) => {
  try {
    const response = await axios.post('http://localhost:4000/api/seller/login', loginData, {
      headers: {
        'Content-Type': 'application/json', // Ensure data is sent as JSON
      },
    });
    return response;
  } catch (error) {
    throw error;
  }
};
