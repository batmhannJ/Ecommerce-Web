import React, { useState } from 'react';
import './SellerProfile.css';

const SellerProfile = () => {
  const [profileData, setProfileData] = useState({
    shopName: '',
    description: '',
    contactNumber: ''
  });

  const [profileErrors, setProfileErrors] = useState({});
  const [profileUpdated, setProfileUpdated] = useState(false);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setProfileData({ ...profileData, [name]: value });
  };

  const validateProfile = () => {
    const errors = {};
    if (!profileData.shopName) errors.shopName = 'Shop Name is required';
    if (!profileData.contactNumber) errors.contactNumber = 'Contact Number is required';
    if (!profileData.description) errors.description = 'Description is required';
    setProfileErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (validateProfile()) {
      setProfileUpdated(true);
      // Handle profile update logic here
    }
  };

  return (
    <div className='seller-profile'>
      <div className='seller-profile-container'>
        <h1 className='seller-profile__heading'>Seller Profile</h1>
        
        {profileUpdated && <p className='seller-profile__success'>Profile updated successfully!</p>}
        
        <form className='seller-profile__form' onSubmit={handleSubmit}>
          <div className='seller-profile__form-group'>
            <label htmlFor='shopName'>Shop Name <span>*</span></label>
            <input
              type='text'
              name='shopName'
              id='shopName'
              value={profileData.shopName}
              onChange={handleChange}
              aria-required='true'
            />
            {profileErrors.shopName && <span className='seller-profile__error'>{profileErrors.shopName}</span>}
          </div>

          <div className='seller-profile__form-group'>
            <label htmlFor='description'>Description <span>*</span></label>
            <textarea
              name='description'
              id='description'
              value={profileData.description}
              onChange={handleChange}
              aria-required='true'
            />
            {profileErrors.description && <span className='seller-profile__error'>{profileErrors.description}</span>}
          </div>

          <div className='seller-profile__form-group'>
            <label htmlFor='contactNumber'>Contact Number <span>*</span></label>
            <input
              type='text'
              name='contactNumber'
              id='contactNumber'
              value={profileData.contactNumber}
              onChange={handleChange}
              aria-required='true'
            />
            {profileErrors.contactNumber && <span className='seller-profile__error'>{profileErrors.contactNumber}</span>}
          </div>
          
          <button className='seller-profile__button' type='submit'>
            Save Changes
          </button>
        </form>
      </div>
    </div>
  );
};

export default SellerProfile;
