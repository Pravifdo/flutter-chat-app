const Message = require("../models/message");

//Send a message
const sendMessage = async (req, res) => {
    try{
        const {senderId, receiverId, message} = req.body;

        const msg = await Message.create({
            senderId, 
            receiverId, 
            message
        });
        res.json(msg);
    }catch(err){
        res.status(500).json({error: err.message});
    }

};

//Get messages between two users
const getMessages = async (req, res) => {
    try{
        const {user1, user2} = req.params;

        const messages = await Message.find({
            $or: [
                {senderId: user1, receiverId: user2},
                {senderId: user2, receiverId: user1}
            ]
        }).sort({createdAt: 1}); // Sort by creation time
        res.json(messages);
    }catch(err){
        res.status(500).json({error: err.message});
    }
};

module.exports = {sendMessage, getMessages};