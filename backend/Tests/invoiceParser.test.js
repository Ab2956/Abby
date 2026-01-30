require('dotenv').config();
const InvoiceParser = require('../src/invoiceSystem/invoiceParser');
const PdfParser = require('../src/invoiceSystem/PdfParser');
const ImageParser = require('../src/invoiceSystem/imageParser');
const fs = require('fs');
const invoviceSchema = require('../src/models/invoiceSchema');

describe('Invoice Parsers', () => {
    let pdfParser;
    let imageParser;

    const TestInvoice = new invoviceSchema({
        vendor: "Test Vendor",
        date: "2024-01-01",
        totalAmount: 100.00,
        taxAmount: 20.00,
        items: [
            { description: "Item 1", amount: 50.00 },
            { description: "Item 2", amount: 50.00 }
        ]
    });
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
    describe('Test pasers output to format', () => {
        test('Pdf parser test', () => {
            const file = {};

            const parsedFile = pdfParser.parseFile(file);

            expect(file).toBe(TestInvoice);
        });
        test('Image parser test', () => {
            const file = {};

            const parsedFile = imageParser.parseFile(file);

            expect(file).toBe(TestInvoice);
        });
    });
});