const invoiceParser = require('./invoiceParser');
const tesseract = require('tesseract.js');
const invoiceSchema = require('../models/InvoiceModel');
const extractionHelper = require('../utils/extractionHelper');

class ImageParser extends invoiceParser {

    constructor() {
        super();
    }
    parseFile() {

    };
}
module.exports = { ImageParser };