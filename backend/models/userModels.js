const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name: {
    type: String,
  },
  email: {
    type: String,
    unique: true,
  },
  password: {
    type: String,
  },
  cartData: {
    type: Object,
  },
  otp: {
    type: String,
    default: null
  },
  date: {
    type: Date,
    default: Date.now,
  }
});

const Users = mongoose.model('Users', UserSchema);

module.exports = Users;
