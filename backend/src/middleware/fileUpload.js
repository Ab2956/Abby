const multer = require("multer");

// middleware for handling file uploads using multer

const storage = multer.diskStorage({
    destination: async(req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + '-' + file.originalname);
    }
});

const upload = multer({
    storage: storage,
    limits: { fileSize: 10 * 1024 * 1024 },
    fileFilter: (req, file, cb) => {
        const allowedFiles = ['image/jpeg', 'image/png', 'image/jpg', 'application/pdf'];
        if (allowedFiles.includes(file.mimetype)) {
            cb(null, true);
        } else {
            cb(new Error('Invalid file type'))
        }
    }
});

module.exports = upload;