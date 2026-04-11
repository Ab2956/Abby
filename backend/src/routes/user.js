const express = require('express');
const router = express.Router();

const { jwtVerification } = require('../middleware/jwtAuth');
const userController = require('../controllers/userController');

router.get('/getUserName', jwtVerification, userController.getUserName);
router.post('/updateUserName', jwtVerification, userController.addUserName);
router.get('/updateVrn', jwtVerification, userController.updateVrn);
router.get('/getVrn', jwtVerification, userController.getVrn);
router.get('/getEmail', jwtVerification, userController.getEmail);
router.post('/updateEmail', jwtVerification, userController.addEmail);
module.exports = router;