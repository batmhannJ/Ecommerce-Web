import React, { useState } from 'react';
import './AccountSettings.css';

const AccountSettings = () => {
  const [formData, setFormData] = useState({
    name: '',
    phone: '',
    email: ''
  });

  const [formErrors, setFormErrors] = useState({});
  const [formSubmitted, setFormSubmitted] = useState(false);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
  };

  const validateForm = () => {
    const errors = {};
    if (!formData.name) errors.name = 'Name is required';
    if (!formData.phone) errors.phone = 'Phone is required';
    if (!formData.email) errors.email = 'Email is required';
    setFormErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (validateForm()) {
      setFormSubmitted(true);
      // Handle form submission logic
    }
  };

  return (
    <div className='account-settings'>
      <div className='account-settings-container'>
        <h1 className='account-settings__heading'>Personal Information</h1>
        
        {formSubmitted && <p className='account-settings__success'>Changes saved successfully!</p>}
        
        <form className='account-settings__form' onSubmit={handleSubmit}>
          <div className='account-settings__form-group'>
            <label htmlFor='name'>Your Name <span>*</span></label>
            <input
              type='text'
              name='name'
              id='name'
              value={formData.name}
              onChange={handleChange}
              aria-required='true'
            />
            {formErrors.name && <span className='account-settings__error'>{formErrors.name}</span>}
          </div>

          <div className='account-settings__form-group'> 
            <label htmlFor='phone'>Phone/Mobile <span>*</span></label>
            <input
              type='text'
              name='phone'
              id='phone'
              value={formData.phone}
              onChange={handleChange}
              aria-required='true'
            />
            {formErrors.phone && <span className='account-settings__error'>{formErrors.phone}</span>}
          </div>

          <div className='account-settings__form-group'> 
            <label htmlFor='email'>Email <span>*</span></label>
            <input
              type='text'
              name='email'
              id='email'
              value={formData.email}
              onChange={handleChange}
              aria-required='true'
            />
            {formErrors.email && <span className='account-settings__error'>{formErrors.email}</span>}
          </div>
          
          <button className='account-settings__button' type='submit'>
            Save Changes
          </button>
        </form>
      </div>
    </div>
  );
};

export default AccountSettings;
