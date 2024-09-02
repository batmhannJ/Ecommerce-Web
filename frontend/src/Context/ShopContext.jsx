import React, { createContext, useEffect, useState } from "react";

export const ShopContext = createContext(null);

const getDefaultCart = () => {
  let cart = {};
  for (let index = 0; index < 300 + 1; index++) {
    cart[index] = { quantity: 0, size: '', price: 0 };
  }
  return cart;
};

const ShopContextProvider = (props) => {
  const [all_product, setAll_Product] = useState([]);
  const [cartItems, setCartItems] = useState(getDefaultCart());

  useEffect(() => {
    fetch("http://localhost:4000/allproducts")
      .then((response) => response.json())
      .then((data) => setAll_Product(data));

    const authToken = localStorage.getItem("auth-token");
    if (authToken) {
      fetch("http://localhost:4000/getcart", {
        method: "POST",
        headers: {
          Accept: "application/json",
          Authorization: `${authToken}`,
          "Content-Type": "application/json",
        },
        body: "",
      })
        .then((response) => response.json())
        .then((data) => setCartItems(data));
    }
  }, []);

  const fetchAllProducts = async () => {
    try {
      const response = await fetch('http://localhost:4000/allproducts'); 
      if (!response.ok) {
        throw new Error('Failed to fetch products');
      }
      const allProducts = await response.json();
      return allProducts;
    } catch (error) {
      console.error('Error fetching products:', error);
      return [];
    }
  };
  
  const prepareOrderItems = async (cartItems) => {
    const allProducts = await fetchAllProducts();
    console.log('Cart Items:', cartItems); // Debugging line
    console.log('All Products:', allProducts); // Debugging line

    let orderItems = [];
    allProducts.forEach((item) => {
      if (cartItems[item._id] && cartItems[item._id].quantity > 0) {
        let itemInfo = { ...item };
        itemInfo["quantity"] = cartItems[item._id].quantity;
        itemInfo["size"] = cartItems[item._id].size;
        itemInfo["price"] = cartItems[item._id].price;
        orderItems.push(itemInfo);
      }
    });
    console.log('Order Items:', orderItems);
    return orderItems;
  };

  const addToCart = (itemId, size, price) => {
    setCartItems((prev) => ({ 
      ...prev, 
      [itemId]: { 
        quantity: (prev[itemId]?.quantity || 0) + 1, 
        size: size, 
        price: price 
      } 
    }));
    const authToken = localStorage.getItem("auth-token");
    if (authToken) {
      fetch("http://localhost:4000/addtocart", {
        method: "POST",
        headers: {
          Accept: "application/json",
          Authorization: `${authToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ itemId, size, price }),
      })
        .then((response) => {
          if (!response.ok) {
            throw new Error("Network response was not ok");
          }
          return response.json();
        })
        .then((data) => {
          console.log(data);
        })
        .catch((error) => {
          console.error("There was a problem with the fetch operation:", error);
        });
    }
  };

  const removeFromCart = (itemId) => {
    setCartItems((prev) => {
      const newQuantity = (prev[itemId]?.quantity || 0) - 1;
      return { 
        ...prev, 
        [itemId]: { 
          quantity: newQuantity > 0 ? newQuantity : 0, 
          size: prev[itemId]?.size || '', 
          price: prev[itemId]?.price || 0 
        } 
      };
    });
    const authToken = localStorage.getItem("auth-token");
    if (authToken) {
      fetch("http://localhost:4000/removefromcart", {
        method: "POST",
        headers: {
          Accept: "application/json",
          Authorization: `${authToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ itemId }),
      })
        .then((response) => response.json())
        .then((data) => console.log(data));
    }
  };

  const getTotalCartAmount = () => {
    let totalAmount = 0;
    for (const item in cartItems) {
      if (cartItems[item].quantity > 0) {
        totalAmount += cartItems[item].price * cartItems[item].quantity;
      }
    }
    return totalAmount;
  };

  const getTotalCartItems = () => {
    let totalItem = 0;
    for (const item in cartItems) {
      if (cartItems[item].quantity > 0) {
        totalItem += cartItems[item].quantity;
      }
    }
    return totalItem;
  };

  const contextValue = {
    getTotalCartAmount,
    getTotalCartItems,
    all_product,
    cartItems,
    addToCart,
    removeFromCart,
    prepareOrderItems
  };

  return (
    <ShopContext.Provider value={contextValue}>
      {props.children}
    </ShopContext.Provider>
  );
};

export default ShopContextProvider;
