require('dotenv').config();
const express = require('express');
const db = require('./src/database/connectDB');
const authRoutes = require('./src/routes/auth');
const logibnRoutes = require('./src/routes/login');
const invoiceRoutes = require('./src/routes/invoice');
const bookkeepingRoutes = require('./src/routes/bookkeeping');
const vatRoutes = require('./src/routes/vat');


const app = express();
const openDbConnection = db.createConnection();
app.use(express.json());

app.get('/', (req, res) => {

    res.send('API is running...');
});

app.use(authRoutes);
app.use(logibnRoutes);
app.use(invoiceRoutes);
app.use(bookkeepingRoutes);
app.use(vatRoutes);

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => console.log(`Server started on port ${PORT}`));