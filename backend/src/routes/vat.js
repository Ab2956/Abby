const express = require('express');
const router = express.Router();

const verifyJWT = require('../middleware/jwtAuth');
const obligations = require('../services/hmrcServices');

router.get('/vat',verifyJWT,obligations.get)

