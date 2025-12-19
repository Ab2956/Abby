const express = require('express');
const router = express.Router();
const loginController = require('../controllers/loginController');
const { jwtVerification } = require('../middleware/jwtAuth');

router.post('/login', loginController.login);
router.get('/profile', jwtVerification, loginController.getProfile);
router.post('/registerAccount', loginController.createAccount);

module.exports = router;