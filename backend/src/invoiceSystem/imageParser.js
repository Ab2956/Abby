const invoiceParser = require('./invoiceParser');
const tesseract = require('tesseract.js');
const invoiceSchema = require('../models/InvoiceModel');
const extractionHelper = require('../utils/extractionHelper');

class ImageParser extends invoiceParser {

    parseFile() {

    };
}
module.exports = { ImageParser };