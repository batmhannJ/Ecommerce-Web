import axios from 'axios';

const API_URL = 'http://localhost:4000/api/seller';

export const sellerSignup = async (data) => {
  const response = await axios.post(`${API_URL}/signup`, data);
  return response.data;
};

export const sellerLogin = async (data) => {
  const response = await axios.post(`${API_URL}/login`, data);
  return response.data;
};
