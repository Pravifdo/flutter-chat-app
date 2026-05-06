const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const connectDB = require("./config/db");
const authRoutes = require("./routes/authRoutes");
const messageRoutes = require("./routes/messageRoutes");
const http = require("http");
const socketIo = require("socket.io");


dotenv.config();

// Connect to MongoDB
connectDB();

const server = http.createServer(app);
const io = socketIo(server);

io.on("connection", (socket) => {
  console.log("New client connected");
});

//join  chat room
io.on("connection", (socket) => {
  socket.on("joinRoom", (room) => {
    socket.join(room);
    console.log(`User joined room: ${room}`);
  });
});

//end message
io.on("connection", (socket) => {
  socket.on("sendMessage", ({ room, message }) => {
    io.to(room).emit("receiveMessage", { room, message });
  });
});

const app = express();

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.send("Chat App Backend Running 🚀");
});

const PORT = process.env.PORT || 5000;

server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

// Routes
app.use("/api/auth",authRoutes);
app.use("/api/messages", messageRoutes);