require('dotenv').config();
const InvoiceParser = require('../src/invoiceSystem/invoiceParser');
const PdfParser = require('../src/invoiceSystem/pdfParser').PdfParser;
const ImageParser = require('../src/invoiceSystem/imageParser');

describe('Invoice Parsers', () => {
    let pdfParser;
    let imageParser;
    beforeEach(() => {
        pdfParser = new PdfParser();
        imageParser = new ImageParser();
    });

    test('PdfParser should be instance of InvoiceParser', () => {
        expect(pdfParser).toBeInstanceOf(InvoiceParser);
    });
    test('ImageParser should be instance of InvoiceParser', () => {
        expect(imageParser).toBeInstanceOf(InvoiceParser);
    });
});