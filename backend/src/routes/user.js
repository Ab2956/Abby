const express = require('express');
const router = express.Router();

const { jwtVerification } = require('../middleware/jwtAuth');
const userController = require('../controllers/userController');

// Routes for user information management, all routes require JWT verification

router.get('/getUserInfo', jwtVerification, userController.getUserInfo);
router.post('/updateUserInfo', jwtVerification, userController.updateUserInfo);
router.post('/updateUserName', jwtVerification, userController.addUserName);
router.post('/updateVrn', jwtVerification, userController.updateVrn);
router.post('/updatePassword', jwtVerification, userController.updatePassword);
module.exports = router;