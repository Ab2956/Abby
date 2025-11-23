require('dotenv').config();
const express = require('express');
const db = require('../backend/src/database/connectDB');
const authRoutes = require('../backend/src/routes/auth');
const logibnRoutes = require('../backend/src/routes/login');


const app = express();
const openDbConnection = db.connectDB();
app.use(express.json());

app.get('/', (req, res) => {

    res.send('API is running...');
});

app.use(authRoutes);
app.use(logibnRoutes);

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => console.log(`Server started on port ${PORT}`));