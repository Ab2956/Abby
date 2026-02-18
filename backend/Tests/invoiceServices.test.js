require('dotenv').config();
const InvoiceServices = require('../src/services/invoiceServices');
const { PdfParser } = require('../src/invoiceSystem/pdfParser');
const { closeConnection } = require('../src/database/connectDB');
const db = require('../src/database/connectDB');
const { ObjectId } = require('mongodb');
const fs = require('fs');
const path = require('path');

describe('Test Invoice Services', () => {

    afterAll(async() => {
        await closeConnection();
    });

    afterEach(async() => {
        const userId = new ObjectId('68fa2057b845e279d8dc41a9');
        const invoiceColl = await db.getCollection('invoices');
        await invoiceColl.deleteOne({ userId: userId });
    });

    test('should add invoice to db', async() => {
        const userId = '68fa2057b845e279d8dc41a9';
        const parser = new PdfParser();
        const filePath = path.join(__dirname, 'testFiles', 'test_invoice.pdf');

        const mockBuffer = fs.readFileSync(filePath);
        expect(mockBuffer).toBeInstanceOf(Buffer);
        expect(mockBuffer.length).toBeGreaterThan(0);
        const result = await parser.parseFile(mockBuffer);

        const addResult = await InvoiceServices.addInvoice(userId, result);
        expect(addResult).toBeDefined();
        expect(addResult.insertedId).toBeDefined();

        // Get invoices for this specific user
        const invoices = await InvoiceServices.getInvoices(userId);
        expect(invoices).toBeDefined();
        expect(Array.isArray(invoices)).toBe(true);
        expect(invoices.length).toBeGreaterThan(0);

        // Verify the invoice has the userId
        const addedInvoice = invoices.find(inv => inv._id.toString() === addResult.insertedId.toString());
        expect(addedInvoice).toBeDefined();
        expect(addedInvoice.userId.toString()).toBe(userId);

    });
    test('should get all invoices from db', async() => {
        const invoices = await InvoiceServices.getInvoices();
        expect(invoices).toBeDefined();
        expect(Array.isArray(invoices)).toBe(true);

        console.log(invoices);
    });
})