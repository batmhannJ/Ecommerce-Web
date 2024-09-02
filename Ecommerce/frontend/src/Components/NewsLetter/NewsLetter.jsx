import React from 'react';
import './NewsLetter.css';
import News_image from '../Assets/News_image.png';

const NewsLetter = () => {
  return (
    <div className='newsletter'>
      <div className='newsletter-content'>
        <img src={News_image} alt="Newsletter" />
        <div className='newsletter-form'>
          <input type="email" placeholder='Your Email ID' />
          <button>Subscribe</button>
        </div>
      </div>
    </div>
  );
};

export default NewsLetter;
