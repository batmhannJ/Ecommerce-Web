import React, { useContext } from "react";
import "./CartItems.css";
import { ShopContext } from "../../Context/ShopContext";
import { useNavigate } from "react-router-dom";
import remove_icon from "../Assets/remove_icon.png";
import { toast } from "react-toastify";

export const CartItems = () => {
  const {
    getTotalCartAmount,
    all_product,
    cartItems,
    removeFromCart,
    updateQuantity,
  } = useContext(ShopContext);
  const navigate = useNavigate();

  const handleProceedToCheckout = () => {
    const token = localStorage.getItem("auth-token");
    if (token) {
      navigate("/order");
    } else {
      toast.error(
        "You are not logged in. Please log in to proceed to checkout.",
        {
          position: "top-left",
        }
      );
      navigate("/login");
    }
  };

  const getCartItemsDetailsAsJson = () => {
    const cartDetails = all_product
      .filter(
        (product) => cartItems[product.id] && cartItems[product.id].quantity > 0
      )
      .map((product) => ({
        name: product.name,
        price: cartItems[product.id].price,
        quantity: cartItems[product.id].quantity,
      }));

    return JSON.stringify(cartDetails, null, 2);
  };

  const handleQuantityChange = (id, delta) => {
    const currentQuantity = cartItems[id]?.quantity || 0;
    if (currentQuantity + delta >= 0) {
      updateQuantity(id, currentQuantity + delta);
    }
  };

  return (
    <div className="cartitems">
      <div className="cartitems-format-main">
        <p>Products</p>
        <p>Title</p>
        <p>Price</p>
        <p>Size</p>
        <p>Quantity</p>
        <p>Total</p>
        <p>Remove</p>
      </div>
      <hr />
      {all_product && all_product.length > 0 ? (
        all_product.map((product) => {
          if (cartItems[product.id] && cartItems[product.id].quantity > 0) {
            return (
              <div key={product.id}>
                <div className="cartitems-format cartitems-format-main">
                  <img
                    src={product.image || remove_icon}
                    alt=""
                    className="cartitem-product-icon"
                  />
                  <p>{product.name}</p>
                  <p>₱{cartItems[product.id].price}</p>
                  <p>{cartItems[product.id].size}</p>
                  <div className="cartitems-quantity-controls">
                    <button
                      className="cartitems-quantity-button"
                      onClick={() => handleQuantityChange(product.id, -1)}
                    >
                      -
                    </button>
                    <button className="cartitems-quantity-button">
                      {cartItems[product.id].quantity}
                    </button>
                    <button
                      className="cartitems-quantity-button"
                      onClick={() => handleQuantityChange(product.id, 1)}
                    >
                      +
                    </button>
                  </div>
                  <p>
                    ₱
                    {cartItems[product.id].price *
                      cartItems[product.id].quantity}
                  </p>
                  <img
                    className="cartitems-remove-icon"
                    src={remove_icon}
                    onClick={() => {
                      console.log("Removing item:", product.id); // Debugging line
                      removeFromCart(product.id);
                    }}
                    alt="Remove"
                  />
                </div>
                <hr />
              </div>
            );
          }
          return null;
        })
      ) : (
        <p>No products in the cart</p>
      )}
      <div className="cartitems-down">
        <div className="cartitems-total">
          <h1>Cart Totals</h1>
          <div>
            <div className="cartitems-total-item">
              <p>Subtotal</p>
              <p>₱{getTotalCartAmount()}</p>
            </div>
            <hr />
            <div className="cartitems-total-item">
              <p>Delivery Fee</p>
              <p>₱{getTotalCartAmount() === 0 ? 0 : 50}</p>
            </div>
            <hr />
            <div className="cartitems-total-item">
              <h3>Total</h3>
              {getCartItemsDetailsAsJson()}
              <h3>
                ₱{getTotalCartAmount() === 0 ? 0 : getTotalCartAmount() + 50}
              </h3>
            </div>
          </div>
          <button onClick={handleProceedToCheckout}>PROCEED TO CHECKOUT</button>
        </div>
      </div>
    </div>
  );
};

export default CartItems;
