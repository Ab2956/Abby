const express = require('express');
const router = express.Router();
const { jwtVerification } = require('../middleware/jwtAuth');

const mtdController = require('../controllers/mtdController');

// Routes for Making Tax Digital related operations, all routes require JWT verification

router.post('/upload-quarter-data', jwtVerification, mtdController.uploadQuarterData);
router.post('/submit-to-hmrc', jwtVerification, mtdController.submitToHmrc);

module.exports = router;