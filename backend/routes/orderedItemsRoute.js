const express = require("express");
const orderedItemsRouter = express.Router();
const orderedItemsController = require("../controllers/orderedItemsController");

orderedItemsRouter.post("/", orderedItemsController.createOrderedList);
orderedItemsRouter.get("/", orderedItemsController.getOrderedList);
orderedItemsRouter.get("/:id", orderedItemsController.getOrderedListById);
orderedItemsRouter.put("/:id", orderedItemsController.updateOrderedList);
orderedItemsRouter.delete("/:id", orderedItemsController.deleteOrderedList);

module.exports = orderedItemsRouter;
