const invoiceParser = require('./invoiceParser');
const tesseract = require('tesseract.js');
const invoiceSchema = require('../models/InvoiceModel');
const extractionHelper = require('../utils/extractionHelper');

class ImageParser extends invoiceParser {

    // image parser which inherits invoice parser

    async parseFile(buffer) {
        try {
        const { data: { text } } = await tesseract.recognize(buffer, 'eng', { logger: m => console.log(m) }); // using tesseract to extract text from image
        console.log('Extracted Text:', text);

        const invoice = new invoiceSchema({ // extracting the data to format into invoice schema

            invoice_number: this.extractInvoiceNumber(text),
            invoice_date: this.extractDate(text),
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
            total_amount: extractionHelper.extractTotalAmount(text),
            vat: extractionHelper.extractVat(text)
            });

            console.log('Extracted Data:', JSON.stringify(invoice, null, 2));

            await invoice.validate();
            console.log('Invoice data is valid');

            return invoice;

        } catch (error) {
            console.error('Error during OCR processing:', error);
            throw error;
        }

    };
}
module.exports = { ImageParser };