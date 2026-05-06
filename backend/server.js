const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const http = require("http");
const socketIo = require("socket.io");
const connectDB = require("./config/db");
const authRoutes = require("./routes/authRoutes");
const messageRoutes = require("./routes/messageRoutes");

dotenv.config();

// Connect to MongoDB
connectDB();

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/messages", messageRoutes);

app.get("/", (req, res) => {
  res.send("Chat App Backend Running 🚀");
});

// Socket.io connection handling
const userSockets = {}; // Track user -> socket mapping

io.on("connection", (socket) => {
  console.log("New client connected:", socket.id);

  // User joins (authenticate via socket)
  socket.on("userJoined", (userId) => {
    userSockets[userId] = socket.id;
    console.log(`User ${userId} joined with socket ${socket.id}`);
    io.emit("userOnline", userId);
  });

  // User joins a chat room (1-on-1)
  socket.on("joinRoom", (roomId) => {
    socket.join(roomId);
    console.log(`Socket ${socket.id} joined room: ${roomId}`);
  });

  // Send message via socket
  socket.on("sendMessage", ({senderId, receiverId, message, roomId}) => {
    const data = {
      senderId: { _id: senderId },
      receiverId: { _id: receiverId },
      message,
      createdAt: new Date().toISOString()
    };
    
    // Send to all users in the room (including sender)
    io.to(roomId).emit("receiveMessage", data);
    console.log(`Message from ${senderId} to ${receiverId} in room ${roomId}`);
  });

  // User disconnects
  socket.on("disconnect", () => {
    // Find and remove user from tracking
    for (const userId in userSockets) {
      if (userSockets[userId] === socket.id) {
        delete userSockets[userId];
        io.emit("userOffline", userId);
        console.log(`User ${userId} went offline`);
        break;
      }
    }
    console.log("Client disconnected:", socket.id);
  });
});

const PORT = process.env.PORT || 5000;

server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});