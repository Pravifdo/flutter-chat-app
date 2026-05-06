const Message = require("../models/message");
const User = require("../models/user");

//Send a message
const sendMessage = async (req, res) => {
    try{
        const {receiverId, message} = req.body;
        const senderId = req.userId; // From auth middleware

        const msg = await Message.create({
            senderId, 
            receiverId, 
            message
        });
        
        // Populate sender and receiver info
        await msg.populate("senderId", "name email");
        await msg.populate("receiverId", "name email");

        res.json(msg);
    }catch(err){
        res.status(500).json({error: err.message});
    }
};

//Get messages between two users
const getMessages = async (req, res) => {
    try{
        const {otherUserId} = req.params;
        const userId = req.userId; // From auth middleware

        const messages = await Message.find({
            $or: [
                {senderId: userId, receiverId: otherUserId},
                {senderId: otherUserId, receiverId: userId}
            ]
        })
        .populate("senderId", "name email")
        .populate("receiverId", "name email")
        .sort({createdAt: 1});

        res.json(messages);
    }catch(err){
        res.status(500).json({error: err.message});
    }
};

//Get all users (for chat list)
const getAllUsers = async (req, res) => {
    try{
        const userId = req.userId;
        const users = await User.find({_id: {$ne: userId}}).select("_id name email");
        res.json(users);
    }catch(err){
        res.status(500).json({error: err.message});
    }
};

module.exports = {sendMessage, getMessages, getAllUsers};