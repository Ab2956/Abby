require('dotenv').config();
const express = require('express');
const authController = require('./src/controllers/authController');

const app = express();

app.use(express.json());

app.get('/', (req, res) => {

  res.send('API is running...');
});
app.get('/login',authController.login);
app.get('/callback',authController.callback);

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => console.log(`Server started on port ${PORT}`));
