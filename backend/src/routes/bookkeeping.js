const express = require('express');
const router = express.Router();

const bookkeepingController = require("../controllers/bookkeepingController");
const { jwtVerification } = require('../middleware/jwtAuth');

router.post('/addRecipt',jwtVerification,bookkeepingController.addRecipt);
router.get('/getRecipts',jwtVerification,bookkeepingController.getRecipts);
router.get('/getRecipt/:id',jwtVerification,bookkeepingController.getReciptById);
router.delete('/deleteRecipt/:id',jwtVerification,bookkeepingController.deleteRecipt);

module.exports = router;