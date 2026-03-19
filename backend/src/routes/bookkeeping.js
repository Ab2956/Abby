const express = require('express');
const router = express.Router();

const bookkeepingController = require("../controllers/bookkeepingController");
const { jwtVerification } = require('../middleware/jwtAuth');

router.post('/addRecipt', jwtVerification, bookkeepingController.addRecipt);
router.get('/getRecipts', jwtVerification, bookkeepingController.getRecipts);
router.get('/deleteRecipt/:id', jwtVerification, bookkeepingController.deleteRecipt);
router.get('/getReciptById/:id', jwtVerification, bookkeepingController.getReciptById);
router.get('/getAllUserRecipts/:userId', jwtVerification, bookkeepingController.getAllUserRecipts);
module.exports = router;