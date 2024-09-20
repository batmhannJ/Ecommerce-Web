const mongoose = require("mongoose");

const UserSchema = new mongoose.Schema({
  name: {
    type: String,
  },
  phone: {
    type: String,
    unique: true,
    trim: true,
  },
  email: {
    type: String,
    unique: true,
  },
  password: {
    type: String,
  },
  street: {
    type: String,
    require: true,
  },
  barangay: {
    type: String,
    require: true,
  },
  municipality: {
    type: String,
    require: true,
  },
  province: {
    type: String,
    require: true,
  },
  region: {
    type: String,
    require: true,
  },
  country: {
    type: String,
    require: true,
  },
  zip: {
    type: Number,
    require: true,
  },
  cartData: {
    type: Object,
  },
  otp: {
    type: String,
    default: null,
  },
  date: {
    type: Date,
    default: Date.now,
  },
});

const Users = mongoose.model("Users", UserSchema);

module.exports = Users;
