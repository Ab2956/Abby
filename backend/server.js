const express = require('express');
const connectDB = require('./src/database/connectDB'); 

const app = express();

connectDB();

app.use(express.json());

app.get('/', (req, res) => {

  res.send('API is running...');
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server started on port ${PORT}`));
