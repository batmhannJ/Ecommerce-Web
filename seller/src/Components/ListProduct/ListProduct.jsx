import React, { useEffect, useState } from 'react';
import './ListProduct.css';
import remove_icon from '../../assets/remove_icon.png';

export const ListProduct = () => {
  const [allproducts, setAllProducts] = useState([]);
  const [editProduct, setEditProduct] = useState(null);
  const [formData, setFormData] = useState({ name: '', old_price: '', new_price: '', category: '', s_stock: '', m_stock: '', l_stock: '', xl_stock: '', stock:'' });

  const fetchInfo = async () => {
    await fetch('http://localhost:4000/allproducts')
      .then((res) => res.json())
      .then((data) => { setAllProducts(data); });
  };

  useEffect(() => {
    fetchInfo();
  }, []);

  const remove_product = async (id) => {
    await fetch('http://localhost:4000/removeproduct', {
      method: 'POST',
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ id })
    });
    await fetchInfo();
  };

  const handleEdit = (product) => {
    console.log('Editing product ID:', product._id); // I-log ang ID ng product
  
    setEditProduct(product);
    setFormData({ 
      name: product.name, 
      old_price: product.old_price, 
      new_price: product.new_price, 
      category: product.category, 
      s_stock: product.s_stock || '', 
      m_stock: product.m_stock || '', 
      l_stock: product.l_stock || '', 
      xl_stock: product.xl_stock || ''
    });
  };
  
  const updateProduct = async () => {
    console.log('Editing Product ID:', editProduct._id); // Log the raw ID
  
    // Compute the total stock
    const computedStock = (parseInt(formData.s_stock) || 0) + 
                          (parseInt(formData.m_stock) || 0) + 
                          (parseInt(formData.l_stock) || 0) + 
                          (parseInt(formData.xl_stock) || 0);
  
    const response = await fetch('http://localhost:4000/editproduct', {
      method: 'POST',
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        _id: editProduct._id,
        name: formData.name,
        old_price: formData.old_price,
        new_price: formData.new_price,
        category: formData.category,
        s_stock: formData.s_stock,
        m_stock: formData.m_stock,
        l_stock: formData.l_stock,
        xl_stock: formData.xl_stock,
        stock: computedStock,  // Ipasok ang computed stock
      }),
    });
  
    const data = await response.json();
    console.log('Response from server:', data);
  
    if (!response.ok) {
      console.error('Error updating product:', data.message);
    } else {
      setEditProduct(null);
      await fetchInfo();
    }
  };
  
  

  return (
    <div className='list-product'>
      <h1>All Products List</h1>
      <div className="listproduct-format-main">
        <p>Products</p>
        <p>Title</p>
        <p>Old Price</p>
        <p>New Price</p>
        <p>Category</p>
        <p>Stock</p> {/* Displaying size-based stock */}
        <p>Action</p>
      </div>
      <div className="listproduct-allproducts">
        <hr />
        {allproducts.map((product) => (
          <React.Fragment key={product.id}>
            <div className="listproduct-format-main listproduct-format">
              <img src={product.image} alt="" className="listproduct-product-icon" />
              <p>{product.name}</p>
              <p>₱{product.old_price}</p>
              <p>₱{product.new_price}</p>
              <p>{product.category}</p>
              {/* Display stock for different sizes */}
              <p>{product.stock}</p>
              <button onClick={() => handleEdit(product)}>Edit</button>
              <img onClick={() => remove_product(product.id)} className='listproduct-remove-icon' src={remove_icon} alt="Remove" />
            </div>
            <hr />
          </React.Fragment>
        ))}
      </div>

      {editProduct && (
        <div className="edit-form" style={{ padding: '20px', border: '1px solid #ccc', marginTop: '20px' }}>
          <h2>Edit Product</h2>
          <input 
            type="text" 
            value={formData.name} 
            onChange={(e) => setFormData({ ...formData, name: e.target.value })} 
            placeholder="Product Name"
          />
          <input 
            type="number" 
            value={formData.old_price} 
            onChange={(e) => setFormData({ ...formData, old_price: e.target.value })} 
            placeholder="Old Price"
          />
          <input 
            type="number" 
            value={formData.new_price} 
            onChange={(e) => setFormData({ ...formData, new_price: e.target.value })} 
            placeholder="New Price"
          />
          <select 
  value={formData.category} 
  onChange={(e) => setFormData({ ...formData, category: e.target.value })} 
  placeholder="Category"
>
  <option value="" disabled>Select Category</option> {/* Optional default option */}
  <option value="crafts">Craft</option>
  <option value="food">Food</option>
  <option value="clothes">Clothes</option>
</select>

          {/* Fields for different size stocks */}
          <input 
            type="number" 
            value={formData.s_stock} 
            onChange={(e) => setFormData({ ...formData, s_stock: e.target.value })} 
            placeholder="Small Stock"
          />
          <input 
            type="number" 
            value={formData.m_stock} 
            onChange={(e) => setFormData({ ...formData, m_stock: e.target.value })} 
            placeholder="Medium Stock"
          />
          <input 
            type="number" 
            value={formData.l_stock} 
            onChange={(e) => setFormData({ ...formData, l_stock: e.target.value })} 
            placeholder="Large Stock"
          />
          <input 
            type="number" 
            value={formData.xl_stock} 
            onChange={(e) => setFormData({ ...formData, xl_stock: e.target.value })} 
            placeholder="XL Stock"
          />
          <button onClick={updateProduct}>Update</button>
          <button onClick={() => setEditProduct(null)}>Cancel</button>
        </div>
      )}
    </div>
  );
};

export default ListProduct;
