import React, { useState } from "react";
import { toast } from "react-toastify";
import "./AddProduct.css";
import upload_area from "../../assets/upload_area.png";

export const AddProduct = () => {
  const [image, setImage] = useState(null);
  const [productDetails, setProductDetails] = useState({
    name: "",
    image: "",
    category: "crafts",
    new_price: "",
    old_price: "",
    size: "Small",
    stock: "",
    description: "",
  });

  const [errors, setErrors] = useState({
    old_price: "",
    new_price: "",
  });

  const imageHandler = (e) => {
    setImage(e.target.files[0]);
  };

  const changeHandler = (e) => {
    const { name, value } = e.target;

    // Validate numeric input
    if (name === "old_price" || name === "new_price") {
      if (!/^\d*\.?\d*$/.test(value)) {
        setErrors({
          ...errors,
          [name]: "Price must be a number",
        });
      } else {
        setErrors({
          ...errors,
          [name]: "",
        });
      }
    }

    // Update the product details
    setProductDetails({
      ...productDetails,
      [name]: value,
    });

    // Validate that the offer price is not higher than the original price
    if (
      name === "new_price" &&
      value &&
      parseFloat(value) >= parseFloat(productDetails.old_price)
    ) {
      setErrors({
        ...errors,
        new_price: "Offer price must be lower than the original price",
      });
    } else if (
      name === "old_price" &&
      value &&
      parseFloat(productDetails.new_price) >= parseFloat(value)
    ) {
      setErrors({
        ...errors,
        new_price: "Offer price must be lower than the original price",
      });
    } else if (name === "new_price" && !/^\d*\.?\d*$/.test(value)) {
      setErrors({
        ...errors,
        new_price: "Offer price must be a number",
      });
    } else {
      setErrors({
        ...errors,
        new_price: "",
      });
    }
  };

  const Add_Product = async () => {
    if (errors.old_price || errors.new_price) {
      toast.error("Please fix the errors before submitting", {
        position: "top-left",
      });
      return;
    }

    // Validate that the offer price is not higher than the original price
    if (parseFloat(productDetails.new_price) >= parseFloat(productDetails.old_price)) {
      toast.error("Offer price must be lower than the original price", {
        position: "top-left",
      });
      return;
    }

    console.log(productDetails);
    let responseData;
    let product = productDetails;

    let formData = new FormData();
    formData.append("product", image);

    await fetch("http://localhost:4000/upload", {
      method: "POST",
      headers: {
        Accept: "application/json",
      },
      body: formData,
    })
      .then((resp) => resp.json())
      .then((data) => {
        responseData = data;
      });

    if (responseData.success) {
      product.image = responseData.image_url;
      console.log(product);
      await fetch("http://localhost:4000/addproduct", {
        method: "POST",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
        },
        body: JSON.stringify(product),
      })
        .then((resp) => resp.json())
        .then((data) => {
          if (data.success) {
            toast.success("Product Added", {
              position: "top-left",
            });
          } else {
            toast.error("Failed", {
              position: "top-left",
            });
          }
        });
    }
  };

  return (
    <div className="add-product">
      <div className="addproduct-itemfield">
        <p>Product Title</p>
        <input
          value={productDetails.name}
          onChange={changeHandler}
          type="text"
          name="name"
          placeholder="Type Here"
        />
      </div>
      <div className="addproduct-description">
        <p>Product Description</p>
        <textarea
          name="description"
          rows="6"
          placeholder="Write description here"
          onChange={changeHandler}
          required
        ></textarea>
      </div>
      <div className="addproduct-price">
        <div className="addproduct-itemfield">
          <p>Price</p>
          <input
            value={productDetails.old_price}
            onChange={changeHandler}
            type="text"
            name="old_price"
            placeholder="Type Here"
          />
          {errors.old_price && (
            <span className="error-text">{errors.old_price}</span>
          )}
        </div>
        <div className="addproduct-itemfield">
          <p>Offer Price</p>
          <input
            value={productDetails.new_price}
            onChange={changeHandler}
            type="text"
            name="new_price"
            placeholder="Type Here"
          />
          {errors.new_price && (
            <span className="error-text">{errors.new_price}</span>
          )}
        </div>
      </div>
      <div className="addproduct-price">
      <div className="addproduct-itemfield">
        <p>Size</p>
        <select
          value={productDetails.size}
          onChange={changeHandler}
          name="size"
          id="size"
          className="add-product-selector"
        >
          <option value="Small">Small</option>
          <option value="Medium">Medium</option>
          <option value="Large">Large</option>
          <option value="XL">XL</option>
        </select>
      </div>
      <div className="addproduct-itemfield">
        <p>No. of Stocks</p>
        <input
          value={productDetails.stock}
          onChange={changeHandler}
          name="stock"
          min="0"
          type="number"
        >
        </input>
        </div>
        <div className="addproduct-itemfield">
        <p>Product Category</p>
        <select
          value={productDetails.category}
          onChange={changeHandler}
          name="category"
          className="add-product-selector"
        >
          <option value="crafts">Crafts</option>
          <option value="clothes">Clothes</option>
          <option value="food">Food</option>
        </select>
      </div>
      
      </div>

      <div className="addproduct-itemfield">
        <label htmlFor="file-input">
          <img
            src={image ? URL.createObjectURL(image) : upload_area}
            className="addproduct-thumbnail-img"
            alt=""
          />
        </label>
        <input
          onChange={imageHandler}
          type="file"
          name="image"
          id="file-input"
          hidden
        />
      </div>

      <button onClick={Add_Product} className="addproduct-btn">
        ADD
      </button>
    </div>
  );
};

export default AddProduct;
