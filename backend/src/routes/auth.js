const express = require('express');
const router = express.Router();

const authController = require('../controllers/authController');
const { jwtVerification } = require('../middleware/jwtAuth');

router.get('/loginAuth',jwtVerification,authController.loginToOAuth);
router.get('/testAuth',authController.testOAuth);
router.get('/callback',authController.callback);

module.exports = router;
