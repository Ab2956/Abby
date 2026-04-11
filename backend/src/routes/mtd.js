const express = require('express');
const router = express.Router();
const { jwtVerification } = require('../middleware/jwtAuth');

const mtdController = require('../controllers/mtdController');

router.post('/upload-quarter-data', jwtVerification, mtdController.uploadQuarterData);
router.post('/submit-to-hmrc', jwtVerification, mtdController.submitToHmrc);

module.exports = router;