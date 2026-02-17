const InvoiceParser = require('./invoiceParser');
const pdf = require('pdf-parse');
const invoiceSchema = require('../models/InvoiceModel');
const extractionHelper = require('../utils/extractionHelper');

class PdfParser extends InvoiceParser {

    // pdf parser which inherits invoice parser

    async parseFile(buffer) {
        try {
            const data = await pdf(buffer); // using pdf-parse to extract text from a pdf file
            const text = data.text || data.textContent; 

            const invoice = new invoiceSchema({ // extracting the data to format into invoice schema

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
                total_amount: extractionHelper.extractTotalAmount(text),
                vat_amount: extractionHelper.extractVatAmount(text)
            });
            await invoice.validate();

            return invoice.toObject();

        } catch (error) {
            throw new Error(`PDF parsing failed: ${error.message}`);
        }
    }

}

module.exports = { PdfParser };