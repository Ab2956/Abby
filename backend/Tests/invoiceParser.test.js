require('dotenv').config();
const { PdfParser } = require('../src/invoiceSystem/pdfParser');
const { ImageParser } = require('../src/invoiceSystem/imageParser');
const fs = require('fs');
const path = require('path');
const invoviceSchema = require('../src/models/InvoiceModel');

describe('Invoice Parsers', () => {

    const pdfParser = new PdfParser();
    const imageParser = new ImageParser();

    const TestInvoice = new invoviceSchema({
        invoice_number: 'INV-001',
        invoice_date: new Date('2023-01-01'),
        suplier: {
            suplier_name: 'Abby',
            suplier_address: '123 Supplier St, City, Country',
            suplier_vat_number: 'VAT123456',
        },
        customer: {
            customer_name: 'Customer LLC',
            customer_address: '456 Customer Ave, City, Country',
        },
        items: [{
                description: 'Product A',
                quantity: 2,
                unit_price: 50.0,
                vat_rate: 0.2,
            },
            {
                description: 'Product B',
                quantity: 1,
                unit_price: 100.0,
                vat_rate: 0.2,
            },
        ],
        total_amount: 240.0,


    });
    beforeAll(() => {

    });

    test('PdfParser should be intailised', () => {
        expect(pdfParser).toBeInstanceOf(PdfParser);
    });
    test('ImageParser should be intailised', () => {
        expect(imageParser).toBeInstanceOf(ImageParser);
    });

    test('pdf parser can extract text from pdf file', async() => {
        const parser = new PdfParser();
        const filePath = path.join(__dirname, 'testFiles', 'test_invoice.pdf');
        const mockBuffer = fs.readFileSync(filePath);

        const result = await parser.parseFile(mockBuffer);

        expect(result).toBeDefined();
        console.log(result);

    });

    describe('Test pasers output to format', () => {
        // test('Pdf parser test', () => {
        //     const parsedFile = pdfParser.parseFile(pdfFile);

        //     expect(parsedFile).toBe(TestInvoice);
        // });
        // test('Image parser test', () => {

        //     const parsedFile = imageParser.parseFile(file);

        //     expect(file).toBe(TestInvoice);
        // });
    });
});