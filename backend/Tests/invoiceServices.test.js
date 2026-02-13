require('dotenv').config();
const InvoiceServices = require('../src/services/invoiceServices');
const { PdfParser } = require('../src/invoiceSystem/pdfParser');
const fs = require('fs');
const path = require('path');

describe('Test Invoice Services', () => {

    test('should add invoice to db', async () => {
        const parser = new PdfParser();
                const filePath = path.join(__dirname, 'testFiles', 'test_invoice.pdf');
        
                const mockBuffer = fs.readFileSync(filePath);
                expect(mockBuffer).toBeInstanceOf(Buffer);
                expect(mockBuffer.length).toBeGreaterThan(0);
                const result = await parser.parseFile(mockBuffer);

                InvoiceServices.addInvoice(result);

    });
})