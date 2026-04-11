const express = require('express');
const router = express.Router();

const { jwtVerification } = require('../middleware/jwtAuth');
const obligationsController = require('../controllers/obligationsController');
const vatController = require('../controllers/vatController');

// Routes for VAT obligations and total VAT calculation, all routes require JWT verification

router.get('/vat',jwtVerification,obligationsController.getObligations);
router.post('/vat',jwtVerification,obligationsController.submitObligation);
router.get('/totalVat',jwtVerification,vatController.getTotalVat);

module.exports = router;