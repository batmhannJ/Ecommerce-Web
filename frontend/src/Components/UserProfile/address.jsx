import React, { useState, useEffect } from "react";
import "./AccountSettings.css";
import axios from "axios";

const Address = () => {
  const [formData, setFormData] = useState({
    fullName: "",
    phoneNumber: "",
    street: "",
    barangay: "",
    municipality: "",
    province: "",
    region: "",
    zip: "",
    country: "Philippines",
  });

  const [provinces, setProvinces] = useState([]);
  const [cities, setCities] = useState([]);
  const [barangays, setBarangays] = useState([]);

  // Fetch provinces when region is selected
  useEffect(() => {
    if (formData.region) {
      axios
        .get(`https://localhost:4000/api/regions/${formData.region}/provinces`)
        .then((response) => setProvinces(response.data))
        .catch((error) => console.error("Error fetching provinces:", error));
    }
  }, [formData.region]);

  // Fetch cities when a province is selected
  useEffect(() => {
    if (formData.province) {
      axios
        .get(`https://localhost:4000/api/provinces/${formData.province}/cities`)
        .then((response) => setCities(response.data))
        .catch((error) => console.error("Error fetching cities:", error));
    }
  }, [formData.province]);

  // Fetch barangays when a city is selected
  useEffect(() => {
    if (formData.municipality) {
      axios
        .get(`https://localhost:4000/api/cities/${formData.municipality}/barangays`)
        .then((response) => setBarangays(response.data))
        .catch((error) => console.error("Error fetching barangays:", error));
    }
  }, [formData.municipality]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
  };

  const validateForm = () => {
    const errors = {};
    // Add validation rules here
    return Object.keys(errors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (validateForm()) {
      try {
        const response = await axios.patch(
          `http://localhost:4000/api/edituser/address`,
          formData
        );
        console.log("Address updated successfully:", response.data);
      } catch (error) {
        console.error("Error updating address:", error);
      }
    }
  };

  return (
    <div className="address-form">
      <h1>New Address</h1>
      <form onSubmit={handleSubmit}>
        {/* Full Name and Phone Number */}
        <div className="form-row">
          <input
            type="text"
            name="fullName"
            placeholder="Full Name"
            value={formData.fullName}
            onChange={handleChange}
          />
          <input
            type="text"
            name="phoneNumber"
            placeholder="Phone Number"
            value={formData.phoneNumber}
            onChange={handleChange}
          />
        </div>

        {/* Region */}
        <div className="form-row">
          <select
            name="region"
            value={formData.region}
            onChange={handleChange}
          >
            <option value="">Region</option>
            <option value="Metro Manila">Metro Manila</option>
            <option value="Mindanao">Mindanao</option>
            <option value="North Luzon">North Luzon</option>
            <option value="South Luzon">South Luzon</option>
            <option value="Visayas">Visayas</option>
          </select>
        </div>

        {/* Province */}
        <div className="form-row">
          <select
            name="province"
            value={formData.province}
            onChange={handleChange}
            disabled={!formData.region}
          >
            <option value="">Province</option>
            {provinces.map((province) => (
              <option key={province.id} value={province.name}>
                {province.name}
              </option>
            ))}
          </select>
        </div>

        {/* City */}
        <div className="form-row">
          <select
            name="municipality"
            value={formData.municipality}
            onChange={handleChange}
            disabled={!formData.province}
          >
            <option value="">City/Municipality</option>
            {cities.map((city) => (
              <option key={city.id} value={city.name}>
                {city.name}
              </option>
            ))}
          </select>
        </div>

        {/* Barangay */}
        <div className="form-row">
          <select
            name="barangay"
            value={formData.barangay}
            onChange={handleChange}
            disabled={!formData.municipality}
          >
            <option value="">Barangay</option>
            {barangays.map((barangay) => (
              <option key={barangay.id} value={barangay.name}>
                {barangay.name}
              </option>
            ))}
          </select>
        </div>

        {/* Submit Button */}
        <div className="form-row">
          <button type="submit">Submit</button>
        </div>
      </form>
    </div>
  );
};

export default Address;
