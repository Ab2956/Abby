const express = require('express');
const router = express.Router();

const authController = require('../controllers/authController');

router.get('/loginAuth',authController.loginToOAuth);
router.get('/callback',authController.callback);

module.exports = router;
