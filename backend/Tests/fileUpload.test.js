const request = require('supertest');
const express = require('express');
const multer = require('multer');

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowedFiles = ['image/jpeg', 'image/png', 'image/jpg', 'application/pdf'];
    if (allowedFiles.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalide file type'));
    }
  }
});

const app = express();
app.post('/upload', upload.single('file'), (req, res) => {
  res.status(200).json({ filename: req.file.originalname });
});

// error handler to surface multer errors in tests
app.use((err, req, res, next) => {
  res.status(400).json({ message: err.message });
});

describe('File upload middleware', () => {
  test('accepts a jpeg file', async () => {
    const buf = Buffer.from([0xff, 0xd8, 0xff]);
    const res = await request(app)
      .post('/upload')
      .attach('file', buf, { filename: 'test.jpg', contentType: 'image/jpeg' });

    expect(res.statusCode).toBe(200);
    expect(res.body.filename).toBe('test.jpg');
  });

  test('rejects an invalid file type', async () => {
    const buf = Buffer.from('hello');
    const res = await request(app)
      .post('/upload')
      .attach('file', buf, { filename: 'test.txt', contentType: 'text/plain' });

    expect(res.statusCode).toBe(400);
    expect(res.body.message).toMatch(/Invalide file type/);
  });
});
