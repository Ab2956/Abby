const InvoiceParser = require('./invoiceParser');
const pdf = require('pdf-parse');

class PdfParser extends InvoiceParser {

    async parseFile(buffer) {
        try {
            const data = await pdf(buffer);


            //TODO : format into invoice schema
            
            return data.text || data.textContent;

        } catch (error) {
            throw new Error(`PDF parsing failed: ${error.message}`);
        }
    }
}

module.exports = { PdfParser };