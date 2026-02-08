const invoiceParser = require('./invoiceParser');
const tesseract = require('tesseract.js');
const invoiceSchema = require('../models/invoiceSchema');

class ImageParser extends invoiceParser {

    parseFile(file) {
        tesseract.recognize(
            file,
            'eng', { logger: m => console.log(m) }
        ).then(({ data: { text } }) => {

            const invoice = new invoiceSchema({
                invoice_number: this.extractInvoiceNumber(text),
                invoice_date: this.extractDate(text),
                supplier: {
                    supplier_name: this.extractSupplierName(text),
                    supplier_address: this.extractSupplierAddress(text),
                    supplier_contact: this.extractSupplierContact(text),
                    supplier_vat_number: this.extractSupplierVat(text)
                },
                customer: {
                    customer_name: this.extractCustomerName(text),
                    customer_address: this.extractCustomerAddress(text)
                },
                items: this.extractItems(text),
                total_amount: this.extractTotalAmount(text),
                vat: this.extractVat(text)
            });
            return invoice;
        }).catch(err => console.error('Error processing image:', err));
    };
}
module.exports = { ImageParser };