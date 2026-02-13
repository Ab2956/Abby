const express = require('express');
const router = express.Router();

const { jwtVerification } = require('../middleware/jwtAuth');
const obligationsController = require('../controllers/obligationsController');
const vatController = require('../controllers/vatController');

router.get('/vat',jwtVerification,obligationsController.getObligations);
router.post('/vat',jwtVerification,obligationsController.submitObligations);
router.get('/totalVat',jwtVerification,vatController.getTotalVat);

module.exports = router;