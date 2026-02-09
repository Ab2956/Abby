const invoiceParser = require('./invoiceParser');
const tesseract = require('tesseract.js');
const invoiceSchema = require('../models/InvoiceModel');
const extractionHelper = require('../utils/extractionHelper');

class ImageParser extends invoiceParser {

    parseFile(file) {
        tesseract.recognize(
            file,
            'eng', { logger: m => console.log(m) }
        ).then(({ data: { text } }) => {

            const invoice = new invoiceSchema({
                invoice_number: extractionHelper.extractInvoiceNumber(text),
                invoice_date: extractionHelper.extractDate(text),
                supplier: {
                    supplier_name: extractionHelper.extractSupplierName(text),
                    supplier_address: extractionHelper.extractSupplierAddress(text),
                    supplier_contact: extractionHelper.extractSupplierContact(text),
                    supplier_vat_number: extractionHelper.extractSupplierVat(text)
                },
                customer: {
                    customer_name: extractionHelper.extractCustomerName(text),
                    customer_address: extractionHelper.extractCustomerAddress(text)
                },
                items: extractionHelper.extractItems(text),
                // add desc and others
                total_amount: extractionHelper.extractTotalAmount(text),
                vat: extractionHelper.extractVat(text)
            });
            return invoice;
        }).catch(err => console.error('Error processing image:', err));
    };
}
module.exports = { ImageParser };