const express = require('express');
const router = express.Router();

const bookkeepingController = require("../controllers/bookkeepingController");
const { jwtVerification } = require('../middleware/jwtAuth');

router.post('/addRecipt', jwtVerification, bookkeepingController.addRecipt);
router.get('/getRecipts', jwtVerification, bookkeepingController.getRecipts);
router.get('/deleteRecipt/', jwtVerification, bookkeepingController.deleteRecipt);
router.get('/getReciptById/', jwtVerification, bookkeepingController.getReciptById);
router.get('/getAllUserReceipts/', jwtVerification, bookkeepingController.getAllUserRecipts);
module.exports = router;