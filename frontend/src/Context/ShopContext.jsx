import React, { createContext, useEffect, useState } from "react";
import axios from "axios";
export const ShopContext = createContext(null);

const getDefaultCart = () => {
  let cart = {};
  for (let index = 0; index < 300 + 1; index++) {
    cart[index] = { quantity: 0, size: "", price: 0 };
  }
  return cart;
};

const ShopContextProvider = (props) => {
  const [all_product, setAll_Product] = useState([]);
  const [cartItems, setCartItems] = useState(getDefaultCart());
  const [deliveryFee, setDeliveryFee] = useState(0);
  const [users, setUser] = useState(null);

  const saveCartToDatabase = async () => {
    const userId = localStorage.getItem('userId');
    if (!userId) {
      console.error('No user ID found in local storage. Cannot save cart.');
      return;
    }
  
    try {
      await axios.post('http://localhost:4000/api/cart', {
        userId,
        cartItems // Ensure this reflects the updated cart items
      });
      console.log("Cart saved to database successfully.");
    } catch (error) {
      console.error("Error saving cart to database:", error);
    }
  };
  

  const calculateDeliveryFee = (distance) => {
    // Example logic for delivery fee
    const baseFee = 50; // Base delivery fee
    const perKmRate = 10; // Rate per kilometer
    const fee = baseFee + perKmRate * distance;
    setDeliveryFee(fee);
  };

  const getUserDetails = async () => {
    const token = localStorage.getItem("auth-token");
    if (token) {
      try {
        const response = await axios.get("/api/user", {
          headers: { Authorization: `Bearer ${token}` },
        });
        setUser(response.data);
        return response.data; // Return user data
      } catch (error) {
        console.error("Error fetching user details:", error);
        return null; // Handle error accordingly
      }
    }
    return null; // If no token, return null
  };

  // Fetch cart for the specific user
  useEffect(() => {
    const authToken = localStorage.getItem("auth-token");
    const storedUserId = localStorage.getItem('userId');

    if (authToken && storedUserId) {
      setUserId(storedUserId); // Set the userId in state
      fetchCartItems(storedUserId);
    }
  }, []);

useEffect(() => {
  const fetchProducts = async () => {
    const products = await fetchAllProducts();
    setAll_Product(products);
  };

  fetchProducts();

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
      const response = await fetch("http://localhost:4000/allproducts");
      if (!response.ok) {
        throw new Error("Failed to fetch products");
      }
      const allProducts = await response.json();
  
      // Construct the full image URL for each product
      const updatedProducts = allProducts.map(product => {
        // Determine which image to display: edited or main
        const mainImage = product.image ? `http://localhost:4000/images/${product.image}` : null;
        const editedImage = product.editedImage ? `http://localhost:4000/images/${product.editedImage}` : null; // Assuming editedImage is stored in the product object
  
        // Choose the edited image if it exists; otherwise, use the main image
        const imageToDisplay = editedImage || mainImage;
  
        return {
          ...product,
          image: imageToDisplay // Set the selected image
        };
      });
  
      return updatedProducts;
    } catch (error) {
      console.error("Error fetching products:", error);
      return [];
    }
  };
  
  

  const prepareOrderItems = async (cartItems) => {
    const allProducts = await fetchAllProducts();
    console.log("Cart Items:", cartItems); // Debugging line
    console.log("All Products:", allProducts); // Debugging line

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
    console.log("Order Items:", orderItems);
    return orderItems;
  };

  // Function to fetch cart items for a specific user
  const fetchCartItems = async (userId) => {
    try {
      const response = await axios.get(`http://localhost:4000/api/cart/${userId}`, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem("auth-token")}`
        }
      });
      setCartItems(response.data.cartItems); // Assuming the API returns cartItems in response
    } catch (error) {
      console.error("Error fetching cart items:", error);
    }
  };


  const addToCart = async (productId, selectedSize, adjustedPrice, quantity) => {
    const userId = localStorage.getItem('userId'); // Make sure userId exists
    if (!userId) {
      console.error('No user ID found in local storage. Cannot add to cart.');
      return;
    }
  
    // First, get the existing cart
    try {
      const response = await axios.get(`http://localhost:4000/api/cart/${userId}`);
      const existingCart = response.data.cartItems;
  
      // Check if the product with the selected size already exists
      const existingItemIndex = existingCart.findIndex(item => 
        item.productId === productId && item.size === selectedSize
      );
  
      if (existingItemIndex !== -1) {
        // Item exists, update the quantity
        existingCart[existingItemIndex].quantity += quantity;
      } else {
        // Item doesn't exist, add new item
        existingCart.push({
          productId,
          selectedSize: selectedSize, // Adjusted this line
          adjustedPrice: adjustedPrice,
          quantity
        });
      }
  
      // Send the updated cart back to the server
      await axios.post('http://localhost:4000/api/cart', {
        userId,
        cartItems: existingCart
      });
      console.log("Cart updated successfully in frontend"); // Debugging
  
    } catch (error) {
      if (error.response && error.response.status === 404) {
        console.warn('Cart not found, creating a new one.');
        // Create a new cart if it doesn't exist
        await axios.post('http://localhost:4000/api/cart', {
          userId,
          cartItems: [{
            productId,
            selectedSize: selectedSize,
            adjustedPrice: adjustedPrice,
            quantity
          }]
        });
      } else {
        console.error("Error fetching/updating cart in frontend:", error);
      }
    }
  };
  
  

  const updateQuantity = (key, newQuantity) => {
    setCartItems(prevItems => {
      const updatedItems = [...prevItems];
      updatedItems[key].quantity = newQuantity;
      return updatedItems;
    });
  };
  
  const removeFromCart = async (productId, selectedSize) => {
    const userId = localStorage.getItem('userId');
    if (!userId) {
        console.error('No user ID found. Cannot remove item.');
        return;
    }

    const key = `${productId}_${selectedSize}`;
    console.log("Cart Items:", cartItems);
    console.log("Key to remove:", key);

    // Find the index of the item to remove based on productId and selectedSize
    const itemIndex = cartItems.findIndex(item => item.productId === parseInt(productId) && item.selectedSize === selectedSize);

    if (itemIndex === -1) {
        console.error('Item not found in cart.');
        return; // Exit if the item is not found
    }

    // Remove item from local state
    setCartItems(prevItems => {
        const updatedItems = [...prevItems]; // Create a shallow copy of the previous items
        updatedItems.splice(itemIndex, 1); // Remove the item by index
        return updatedItems; // Return the updated items
    });

    // Remove item from the database
    try {
        await axios.delete(`http://localhost:4000/api/cart/${userId}/${productId}?selectedSize=${selectedSize}`);
        console.log("Item removed from database successfully.");
    } catch (error) {
        console.error("Error removing item from database:", error);
    }
};

const clearCart = () => {
  setCartItems({}); // Assuming you're using an object to store cart items by productId
};

  
  const getTotalCartAmount = () => {
    let totalAmount = 0;
    for (const item in cartItems) {
      if (cartItems[item].quantity > 0) {
        totalAmount += cartItems[item].adjustedPrice * cartItems[item].quantity;
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

  const [userId, setUserId] = useState(localStorage.getItem('userId')); // Initialize from localStorage

  const contextValue = {
    getTotalCartAmount,
    getTotalCartItems,
    deliveryFee, // Add delivery fee to context
    all_product,
    cartItems,
    addToCart,
    removeFromCart,
    updateQuantity,
    prepareOrderItems,
    calculateDeliveryFee,
    getUserDetails,
    users,
    userId,
    setUserId,
    setCartItems,
    saveCartToDatabase,
    clearCart
  };

  return (
    <ShopContext.Provider value={contextValue}>
      {props.children}
    </ShopContext.Provider>
  );
};

export default ShopContextProvider;
