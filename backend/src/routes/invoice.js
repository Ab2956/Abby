const express = require('express');
const router = express.Router();
const upload = require("../middleware/fileUpload");
const InvoiceController = require("../controllers/invoiceController");

const invoiceController = new InvoiceController();

router.post('/scanInvoice', upload.single('file'), async (req, res) => {
	try {
		if (!req.file) {
			return res.status(400).json({ 
				success: false,
				message: 'No file uploaded' 
			});
		}

		// Handle file upload using the controller with strategy pattern
		const result = await invoiceController.handleUpload(req.file);
		
		return res.status(200).json(result);
	} catch (err) {
		return res.status(500).json({ 
			success: false,
			message: err.message 
		});
	}
});

module.exports = router;