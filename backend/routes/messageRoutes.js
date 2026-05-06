const express = require('express');
const router = express.Router();
const authMiddleware = require("../middleware/auth");
const {sendMessage, getMessages, getAllUsers} = require("../controllers/messageController");

// All message routes require authentication
router.use(authMiddleware);

//Send a message
router.post("/send", sendMessage);

//Get messages between two users
router.get("/:otherUserId", getMessages);

//Get all users for chat list
router.get("/users/list/all", getAllUsers);

module.exports = router;