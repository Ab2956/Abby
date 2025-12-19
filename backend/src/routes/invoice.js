const express = require('express');
const router = express.Router();
const upload = require("../middleware/fileUpload");

router.post('/scanInvoice', upload.single('file'), uploadController.paserFile)