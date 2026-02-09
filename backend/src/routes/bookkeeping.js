const express = require('express');
const router = express.Router();

const bookkeepingController = require("../controllers/bookkeepingController");
const { jwtVerification } = require('../middleware/jwtAuth');

router.post('/addRecipt',jwtVerification,bookkeepingController.addRecipt);

module.exports = router;