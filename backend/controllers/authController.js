const User = require("../models/user");

//Register a new user
const registerUser = async (req, res) => {
    try{
        const {name,email,password} = req.body;

        const user = await User.create({name,email,password});
        res.json(user);
    }catch(err){
        res.status(500).json({error: err.message});
    }

};

//Login user
const loginUser = async (req, res) => {
    try{
        const{email,password} = req.body;

        const user = await User.findOne({email,password});

        if(!user){
            return res.status(400).json({message: "Invalid credentials"}); 
        }
        res.json(user);
    }catch(err){
        res.status(500).json({error: err.message});
    }
};

module.exports = {registerUser, loginUser};