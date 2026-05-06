const User = require("../models/user");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

//Register a new user
const registerUser = async (req, res) => {
    try{
        const {name, email, password} = req.body;

        // Check if user already exists
        const existingUser = await User.findOne({email});
        if(existingUser){
            return res.status(400).json({message: "Email already registered"});
        }

        // Hash password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Create user
        const user = await User.create({
            name, 
            email, 
            password: hashedPassword
        });

        // Generate JWT token
        const token = jwt.sign(
            {userId: user._id, email: user.email},
            process.env.JWT_SECRET || "your_jwt_secret",
            {expiresIn: "7d"}
        );

        res.status(201).json({
            message: "User registered successfully",
            token,
            user: {_id: user._id, name: user.name, email: user.email}
        });
    }catch(err){
        res.status(500).json({error: err.message});
    }
};

//Login user
const loginUser = async (req, res) => {
    try{
        const {email, password} = req.body;

        // Find user
        const user = await User.findOne({email});
        if(!user){
            return res.status(400).json({message: "Invalid credentials"}); 
        }

        // Compare passwords
        const isMatch = await bcrypt.compare(password, user.password);
        if(!isMatch){
            return res.status(400).json({message: "Invalid credentials"});
        }

        // Generate JWT token
        const token = jwt.sign(
            {userId: user._id, email: user.email},
            process.env.JWT_SECRET || "your_jwt_secret",
            {expiresIn: "7d"}
        );

        res.json({
            message: "Login successful",
            token,
            user: {_id: user._id, name: user.name, email: user.email}
        });
    }catch(err){
        res.status(500).json({error: err.message});
    }
};

module.exports = {registerUser, loginUser};