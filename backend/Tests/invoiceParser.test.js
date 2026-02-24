require('dotenv').config();
const { PdfParser } = require('../src/invoiceSystem/pdfParser');
const { ImageParser } = require('../src/invoiceSystem/imageParser');
const fs = require('fs');
const path = require('path');
const invoviceSchema = require('../src/models/InvoiceModel');
const e = require('express');

describe('Invoice Parsers', () => {

    const pdfParser = new PdfParser();
    const imageParser = new ImageParser();

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
        expect(mockBuffer).toBeInstanceOf(Buffer);
        expect(mockBuffer.length).toBeGreaterThan(0);
        const result = await parser.parseFile(mockBuffer);
        expect(result).toBeDefined();
        expect(result.invoice_number).toBe('INV-0001');
        console.log(result);

    });
    test('image parser can extract text from image file', async() => {
        const imageParser = new ImageParser();
        const filePath = path.join(__dirname, 'testFiles', 'test_invoice_png.png');

        const mockBuffer = fs.readFileSync(filePath);
        expect(mockBuffer).toBeInstanceOf(Buffer);
        expect(mockBuffer.length).toBeGreaterThan(0);
        const result = await imageParser.parseFile(mockBuffer);

        expect(result).toBeDefined();
        expect(result.invoice_number).toBe('INV-100123');
        console.log(result);
    });

    describe('Test pasers output to format', () => {

    });
});;