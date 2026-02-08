const InvoiceParser = require('./invoiceParser');
const pdf = require('pdf-parse');
const invoiceSchema = require('../models/InvoiceModel');
const extractionHelper = require('../utils/extractionHelper');

class PdfParser extends InvoiceParser {

    async parseFile(buffer) {
        try {
            const data = await pdf(buffer);
            const text = data.text || data.textContent;

            console.log('PDF Text:', text);

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
                total_amount: extractionHelper.extractTotalAmount(text),
                vat: extractionHelper.extractVat(text)
            });
            console.log('Extracted Data:', JSON.stringify(invoice, null, 2));
            await invoice.validate();

            return invoice;

        } catch (error) {
            throw new Error(`PDF parsing failed: ${error.message}`);
        }
    }
}

module.exports = { PdfParser };