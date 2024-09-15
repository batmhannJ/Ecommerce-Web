const port = 4000;
const express = require("express");
const app = express();
const mongoose = require("mongoose");
const jwt = require("jsonwebtoken");
const multer = require("multer");
const path = require("path");
const cors = require("cors");

// import routes
const adminRoutes = require('./routes/adminRoute');
const orderRouter = require('./routes/orderRoute');
const sellerRouter = require('./routes/sellerRoute');
const userRoutes = require('./routes/userRoute');
require('dotenv').config();

const mongoURI = process.env.MONGODB_URI;

app.use(cors());
app.use(express.json());
app.use('/api/transactions', transactionRoutes);



// Database Connection
mongoose
  .connect(mongoURI)
  .then(() => console.log("MongoDB connected successfully"))
  .catch((err) => console.error("MongoDB connection error:", err));

// API Creation
app.get("/", (req, res) => {
  res.send("Express App is Running");
});

/* app.post('/paymaya-checkout', async (req, res) => {
  try {
    const response = await axios.post('https://pg-sandbox.paymaya.com/checkout/v1/checkouts', req.body, {
      headers: {
        Authorization: 'Basic WDdZM2VUdnhLUEY5WWRRZzljdmxhckRzWjdiWUNZdjB3blJHOGVpb215cg==',
        'Content-Type': 'application/json'
      }
    });
    res.send(response.data);
  } catch (error) {
    res.status(500).send(error.response ? error.response.data : { error: 'Something went wrong' });
  }
});*/

app.get('/api/transactions', (req, res) => {
  res.json({ message: 'This is the transactions endpoint' });
});

app.listen(port, (error) => {
  if (!error) {
    console.log("Server Running on Port: " + port);
  } else {
    console.log("Error: " + error);
  }
});

// Image Storage Engine
const storage = multer.diskStorage({
  destination: "./upload/images",
  filename: (req, file, cb) => {
    return cb(
      null,
      `${file.fieldname}_${Date.now()}${path.extname(file.originalname)}`
    );
  },
});

const upload = multer({ storage: storage });

// Creating Upload Endpoints for Images
app.use("/images", express.static("upload/images"));

app.post("/upload", upload.single("product"), (req, res) => {
  res.json({
    success: 1,
    image_url: `http://localhost:${port}/images/${req.file.filename}`,
  });
});

const CartItems = require("./models/orderedItemsModel");

// Schema for Creating Products
const Product = require("./models/productModels");

// Creating Middleware to fetch user
const fetchUser = require("./middleware/auth");

// Schema Creation for User Model
const Users = require("./models/userModels");

// Creating PlaceOrder Endpoint
app.use("/api/order", orderRouter);

// Seller Login Sign Up Endpoint
app.use('/api/seller', sellerRouter);

// Fetch all users
app.get("/users", async (req, res) => {
  try {
    const users = await Users.find({});
    res.json(users);
  } catch (error) {
    console.error("Error fetching users:", error);
    res.status(500).json({ error: "Failed to fetch users" });
  }
});

app.post("/api/ordered-items", orderedItemsRouter);
app.get("/getPaidItems", orderedItemsRouter);
app.get("/getOrderedItemsById/:id", async (req, res) => {
  try {
    const orders = await Order.find({});
    res.json(orders);
  } catch (error) {
    console.error("Error fetching orders:", error);
    res.status(500).json({ message: "Internal Server Error" });
  }
});

app.post("/addproduct", async (req, res) => {
  let products = await Product.find({});
  let id;
  if (products.length > 0) {
    let last_product_array = products.slice(-1);
    let last_product = last_product_array[0];
    id = last_product.id + 1;
  } else {
    id = 1;
  }
  const product = new Product({
    id: id,
    name: req.body.name,
    image: req.body.image,
    category: req.body.category,
    new_price: req.body.new_price,
    old_price: req.body.old_price,
    s_stock: req.body.s_stock,
    m_stock: req.body.m_stock,
    l_stock: req.body.l_stock,
    xl_stock: req.body.xl_stock,
    stock: req.body.stock,
    description: req.body.description,
  });
  await product.save();
  console.log(product);
  res.json({
    success: true,
    name: req.body.name,
  });
  const {
    name,
    image,
    category,
    new_price,
    old_price,
    s_stock,
    m_stock,
    l_stock,
    xl_stock,
    stock,
    description,
  } = req.body;

  // Log received product data
  console.log("Received Product Data:", {
    name,
    image,
    category,
    new_price,
    old_price,
    s_stock,
    m_stock,
    l_stock,
    xl_stock,
    stock,
    description,
  });
});

// Creating API for deleting Products
app.post("/removeproduct", async (req, res) => {
  await Product.findOneAndDelete({ id: req.body.id });
  console.log("Removed");
  res.json({
    success: true,
    name: req.body.name,
  });
});

// Creating API for getting All Products
app.get("/allproducts", async (req, res) => {
  let products = await Product.find({});
  console.log("All Products Fetched");
  res.send(products);
});

// Creating Endpoint for Registering the user
app.post("/signup", async (req, res) => {
  let check = await Users.findOne({ email: req.body.email });
  if (check) {
    return res
      .status(400)
      .json({ success: false, errors: "Existing User Found" });
  }
  let cart = {};
  for (let i = 0; i < 300; i++) {
    cart[i] = 0;
  }
  const user = new Users({
    name: req.body.username,
    email: req.body.email,
    password: req.body.password,
    cartData: cart,
  });

  await user.save();

  const data = {
    user: {
      id: user.id,
    },
  };

  const token = jwt.sign(data, "secret_ecom");
  res.json({ success: true, token });
});

// Creating Endpoint for User Login
app.post("/login", async (req, res) => {
  let user = await Users.findOne({ email: req.body.email });
  if (user) {
    const passCompare = req.body.password === user.password;
    if (passCompare) {
      const data = {
        user: {
          id: user.id,
        },
      };
      const token = jwt.sign(data, "secret_ecom");
      res.json({ success: true, token });
    } else {
      res.json({ success: false, errors: "Error: Wrong Password" });
    }
  } else {
    res.json({ success: false, errors: "Error: Wrong Email Address" });
  }
});

// Creating Endpoint for NewCollection Data
app.get("/newcollections", async (req, res) => {
  let products = await Product.find({});
  let newcollection = products.slice(1).slice(-8);
  console.log("NewCollection Fetched");
  res.send(newcollection);
});

// Creating Endpoint for Popular in Crafts Section
app.get("/popularincrafts", async (req, res) => {
  let products = await Product.find({ category: "crafts" });
  let popular_in_crafts = products.slice(5, 9);
  console.log("Popular in Crafts Fetched");
  res.send(popular_in_crafts);
});

// Creating Endpoint for adding products in CartData
app.post("/addtocart", fetchUser, async (req, res) => {
  console.log("added", req.body.itemId);
  let userData = await Users.findOne({ _id: req.user.id });
  userData.cartData[req.body.itemId] += 1;
  await Users.findOneAndUpdate(
    { _id: req.user.id },
    { cartData: userData.cartData }
  );
  res.send("Added");
});

// Creating Endpoint to remove product from CartData
app.post("/removefromcart", fetchUser, async (req, res) => {
  console.log("removed", req.body.itemId);
  let userData = await Users.findOne({ _id: req.user.id });
  if (userData.cartData[req.body.itemId] > 0)
    userData.cartData[req.body.itemId] -= 1;
  await Users.findOneAndUpdate(
    { _id: req.user.id },
    { cartData: userData.cartData }
  );
  res.send("Removed");
});

// Create Endpoint to get CartData
app.post("/getcart", fetchUser, async (req, res) => {
  console.log("GetCart");
  let userData = await Users.findOne({ _id: req.user.id });
  res.json(userData.cartData);
});

// Corrected endpoint to fetch related products based on category
app.get("/relatedproducts/:category", async (req, res) => {
  const category = req.params.category;
  try {
    const relatedProducts = await Product.find({ category });
    console.log("Related Products Fetched");
    res.json(relatedProducts);
  } catch (error) {
    console.error("Error fetching related products:", error);
    res.status(500).json({ error: "Failed to fetch related products" });
  }
});



// Admin Routes
app.use("/api/admin", adminRoutes);
app.use("/api", userRoutes);
