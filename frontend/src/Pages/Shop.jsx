import React from 'react'
import Hero from '../Components/Hero/Hero'
import Popular from '../Components/Popular/Popular'
import Offers from '../Components/Offers/Offers'
import NewCollections from '../Components/NewCollections/NewCollections'
import NewsLetter from '../Components/NewsLetter/NewsLetter'
import About from '../Components/About/About'
import { useUser } from '../Context/UserContext';

const Shop = () => {
  const { user } = useUser();
  console.log("User in Shop component:", user); 
  return (
    <div>
        {user ? (
          <p>Welcome back, {user.id}!</p>
        ) : (
          <p>Welcome to our shop! Please log in.</p>
        )}
      <Hero/>
      <Popular />
      <Offers />
      <NewCollections />
      <NewsLetter />
      <About />
    </div>
  )
}

export default Shop
