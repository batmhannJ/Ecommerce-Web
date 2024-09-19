import React from 'react';
import './Offices.css';
import offices from '../Assets/offices.png';

const Offices = () => {
  return (
    <div className='newsletter'>
      <div className='newsletter-content'>
        <h1>Our Offices</h1>
        <img src={offices} alt="Newsletter" />
      </div>
    </div>
  );
};

export default Offices;
