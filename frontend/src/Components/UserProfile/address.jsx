import React, { useState, useEffect } from "react";
import "./address.css";
import axios from "axios";
import { regions, provincesByCode, cities, barangays } from 'select-philippines-address';

const Address = () => {
  const [formData, setFormData] = useState({
    street: "",
    barangay: "",
    municipality: "",
    province: "",
    region: "",
    zip: "",
    country: "Philippines",
  });

  const [availableRegions, setAvailableRegions] = useState([]);
  const [provinces, setProvinces] = useState([]);
  const [citiesList, setCities] = useState([]);
  const [barangaysList, setBarangays] = useState([]);
  const [restoreData, setRestoreData] = useState(""); // For restoring and updating the data

  // Store selected names to display in restore data
  const [selectedRegion, setSelectedRegion] = useState("");
  const [selectedProvince, setSelectedProvince] = useState("");
  const [selectedCity, setSelectedCity] = useState("");
  const [selectedBarangay, setSelectedBarangay] = useState("");

  // Fetch regions on component mount
  useEffect(() => {
    const fetchRegions = async () => {
      const data = await regions();
      setAvailableRegions(data);
    };

    fetchRegions();
  }, []);

  // Fetch provinces when region is selected
  useEffect(() => {
    const fetchProvinces = async () => {
      if (formData.region) {
        const provincesData = await provincesByCode(formData.region);
        setProvinces(provincesData);

        // Find the selected region name
        const selectedRegionData = availableRegions.find(
          (region) => region.region_code === formData.region
        );
        setSelectedRegion(selectedRegionData?.region_name || "");
      }
    };

    fetchProvinces();
  }, [formData.region]);

  // Fetch cities when a province is selected
  useEffect(() => {
    const fetchCities = async () => {
      if (formData.province) {
        const citiesData = await cities(formData.province);
        setCities(citiesData);

        // Find the selected province name
        const selectedProvinceData = provinces.find(
          (province) => province.province_code === formData.province
        );
        setSelectedProvince(selectedProvinceData?.province_name || "");
      }
    };

    fetchCities();
  }, [formData.province]);

  // Fetch barangays when a city is selected
  useEffect(() => {
    const fetchBarangays = async () => {
      if (formData.municipality) {
        const barangaysData = await barangays(formData.municipality);
        setBarangays(barangaysData);

        // Find the selected city name
        const selectedCityData = citiesList.find(
          (city) => city.city_code === formData.municipality
        );
        setSelectedCity(selectedCityData?.city_name || "");
      }
    };

    fetchBarangays();
  }, [formData.municipality]);

  // Find selected barangay name
  useEffect(() => {
    const selectedBarangayData = barangaysList.find(
      (barangay) => barangay.brgy_code === formData.barangay
    );
    setSelectedBarangay(selectedBarangayData?.brgy_name || "");
  }, [formData.barangay]);

  // Update the restore data field based on current form values (actual names)
  useEffect(() => {
    setRestoreData(
      `${formData.street}, ${selectedRegion}, ${selectedProvince}, ${selectedCity}, ${selectedBarangay}, ${formData.zip}`
    );
  }, [formData, selectedRegion, selectedProvince, selectedCity, selectedBarangay]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
  };

  const validateForm = () => {
    const errors = {};
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

  const handleRestore = () => {
    // Split and trim the restored data, then find matching codes based on names
    const [street, regionName, provinceName, cityName, barangayName, zip] = restoreData.split(",").map(item => item.trim());

    // Restore formData based on region, province, city, and barangay names
    const region = availableRegions.find((region) => region.region_name === regionName)?.region_code || "";
    const province = provinces.find((province) => province.province_name === provinceName)?.province_code || "";
    const municipality = citiesList.find((city) => city.city_name === cityName)?.city_code || "";
    const barangay = barangaysList.find((barangay) => barangay.brgy_name === barangayName)?.brgy_code || "";

    setFormData({
      street,
      region,
      province,
      municipality,
      barangay,
      zip,
      country: "Philippines"
    });
  };

  return (
    <div className="address-form">
      <h1>New Address</h1>
      
      {/* Input box to show and restore previously selected/typed values */}
        <div className="form-row">
          <input
            type="text"
            placeholder={restoreData || "street, region, province, city, barangay, zip"} // Use dynamic placeholder
            value={restoreData}
            onChange={(e) => setRestoreData(e.target.value)}
          />
        </div>


      <form onSubmit={handleSubmit}>
        {/* Street */}
        <div className="form-row">
          <input
            type="text"
            name="street"
            placeholder="Street"
            value={formData.street}
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
            {availableRegions.map((region) => (
              <option key={region.region_code} value={region.region_code}>
                {region.region_name}
              </option>
            ))}
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
              <option key={province.province_code} value={province.province_code}>
                {province.province_name}
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
            {citiesList.map((city) => (
              <option key={city.city_code} value={city.city_code}>
                {city.city_name}
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
            {barangaysList.map((barangay) => (
              <option key={barangay.brgy_code} value={barangay.brgy_code}>
                {barangay.brgy_name}
              </option>
            ))}
          </select>
        </div>

        {/* Zip Code */}
        <div className="form-row">
          <input
            type="text"
            name="zip"
            placeholder="Zip Code"
            value={formData.zip}
            onChange={handleChange}
          />
        </div>

        {/* Country */}
        <div className="form-row">
          <input
            type="text"
            name="country"
            placeholder="Country"
            value={formData.country}
            disabled
          />
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
