const express = require('express');
const router = express.Router();
const upload = require("../middleware/fileUpload");

// POST /scanInvoice
// Accepts a single file under the `file` field and returns basic metadata.
router.post('/scanInvoice', upload.single('file'), (req, res) => {
	try {
		if (!req.file) return res.status(400).json({ message: 'No file uploaded' });

		const info = {
			originalname: req.file.originalname,
			mimetype: req.file.mimetype,
			size: req.file.size,
			// multer.diskStorage will set a `path`; memoryStorage will not
			path: req.file.path || null
		};

		return res.status(200).json({ file: info });
	} catch (err) {
		return res.status(500).json({ message: err.message });
	}
});

module.exports = router;