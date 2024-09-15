const express = require('express');
const router = express.Router();
const Transaction = require('../models/transactionModel'); 

router.post('/api/transactions', async (req, res) => {
    try {
      const { date, name, contact, item, quantity, amount, address, transactionId, status } = req.body;
      
      // Create a new transaction record
      const transaction = new Transaction({
        date,
        name,
        contact,
        item,
        quantity,
        amount,
        address,
        transactionId,
        status,
      });
  
      await transaction.save();
      console.log("Saved Transaction:", transaction);
  
      res.status(201).json({ success: true, message: 'Transaction saved successfully.' });
    } catch (error) {
      console.error('Error saving transaction:', error);
      res.status(500).json({ success: false, message: 'Error saving transaction.' });
    }
  });

// POST transaction route
router.post('/', async (req, res) => {
  try {
    const transaction = new Transaction(req.body);
    await transaction.save();
    res.status(201).send(transaction);
  } catch (error) {
    res.status(400).send(error);
  }
});

// GET transactions route
router.get('/', async (req, res) => {
  try {
    const transactions = await Transaction.find();
    res.status(200).send(transactions);
  } catch (error) {
    res.status(500).send(error);
  }
});
  
// GET specific transaction route
router.get('/:id', async (req, res) => {
  try {
    const transaction = await Transaction.findById(req.params.id);
    if (!transaction) return res.status(404).send('Transaction not found');
    res.status(200).send(transaction);
  } catch (error) {
    res.status(500).send(error);
  }
});

module.exports = router;
