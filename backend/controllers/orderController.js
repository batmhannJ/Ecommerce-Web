const orderModel = require('../models/orderModel');
const userModel = require('../models/userModels');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

const PlaceOrder = async (req, res) => {
  const frontend_url = 'http://localhost:3000';

  try {
    // Debugging: Print the Stripe key to verify it's being read correctly
    console.log("Stripe Secret Key:", process.env.STRIPE_SECRET_KEY);

    // Create new order
    const newOrder = new orderModel({
      userId: req.user.id,
      items: req.body.items,
      amount: req.body.amount,
      address: req.body.address,
    });

    await newOrder.save();
    await userModel.findByIdAndUpdate(req.body.userId, { cartData: {} });

    // Create line items for Stripe
    const line_items = req.body.items.map((item) => ({
      price_data: {
        currency: "php",
        product_data: {
          name: item.name,
        },
        unit_amount: item.price * 100 * 58,
      },
      quantity: item.quantity
    }))

    // Add delivery charges
    line_items.push({
      price_data: {
        currency: "php",
        product_data: {
          name: "Delivery Charges",
        },
        unit_amount: 50 * 100 * 58,
      },
      quantity: 1
    })

    // Create Stripe checkout session
    const session = await stripe.checkout.sessions.create({
      line_items: line_items,
      payment_method_types: ['card'],
      mode: 'payment',
      success_url: `${frontend_url}/verify?success=true&orderId=${newOrder._id}`,
      cancel_url: `${frontend_url}/verify?success=false&orderId=${newOrder._id}`,
    })

    res.json({ success: true, session_url: session.url })

  } catch (error) {
    console.log(error);
    res.json({
      success: false,
      message: 'An error occurred while placing your order. Please try again.'
    })
  }
}

const verifyOrder = async (req, res) => {
  const {orderId, success} = req.body;
  try {
    if (success=="true") {
      await orderModel.findByIdAndUpdate(orderId, {payment: true});
      res.json({success:true, message:"Paid"})
    }
    else {
      await orderModel.findByIdAndDelete(orderId);
      await res.json({success:false, message:"Not Paid"})
    }
  } catch (error) {
    console.log(error);
    res.json({success:false, message:"Error"})
  }
}

// User Orders for Frontend
const userOrders = async (req,res) => {
  try {
    const orders = await orderModel.find({id:req.body.id});
    res.json({success:true,data:orders})
  } catch (error) {
    console.log(error);
    res.json({success:false, message:"Error"})
  }
}

// Listing Orders for Admin Panel
const listOrders = async (req, res) => {
  try {
    const orders = await orderModel.find({});
    res.json({ success:true, data:orders})
  } catch (error) {
    console.log(error);
    res.json({ success:false, message:"Error"})
  }
}

// API for Updating Order Status
 const updateStatus = async (req,res) => {
  try {
    await orderModel.findByIdAndUpdate(req.body.orderId, {status: req.body.status});
    res.json({success:true, message:"Status Updated"})
  } catch (error) {    
    console.log(error);
    res.json({success:false, message:"Error"})
  }
 }

module.exports = { PlaceOrder, verifyOrder, userOrders,listOrders, updateStatus };