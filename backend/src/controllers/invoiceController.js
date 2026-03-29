const InoviceSchema = require("../models/InvoiceModel");
const {PdfParser} = require("../invoiceSystem/pdfParser");
const {ImageParser} = require("../invoiceSystem/imageParser");
const invoiceServices = require("../services/invoiceServices");

const pdfParser = new PdfParser();
const imageParser = new ImageParser();

class InvoiceController {
    constructor() {}

    async handleUpload(file, userId) {

        try {
            if (!file || !file.buffer) {
                throw new Error('No file provided');
            }
            if (file.mimetype == "application/pdf") {
                const parsedFile = await pdfParser.parseFile(file.buffer);
                await invoiceServices.addInvoice(userId, parsedFile);
                return { success: true, message: "Invoice uploaded successfully" };

            } else if (file.mimetype.startsWith("image/")) {
                const parsedFile = await imageParser.parseFile(file.buffer);
                await invoiceServices.addInvoice(userId, parsedFile);
                return { success: true, message: "Invoice uploaded successfully" };

            } else {
                throw new Error('Unsupported file type');
            }

            return { success: true, message: "Invoice uploaded successfully" };
        } catch (error) {
            throw new Error(`File upload failed: ${error.message}`);
        }
    }
    async getAllUserInvoices(req, res) {
        try {
            const userId = req.user.userId;
            const invoices = await userServices.getAllUserInvoices(userId);

            // format the invoice for the frontend
            const normalizeInvoice = (invoice) => ({
                ...invoice,
                _id: invoice._id?.toString(),
                invoice_date: invoice.invoice_date instanceof Date
                    ? invoice.invoice_date.toISOString()
                    : (invoice.invoice_date?.$date || ""),
                supplier: invoice.supplier ? {
                    ...invoice.supplier,
                    _id: undefined
                } : undefined,
                customer: invoice.customer ? {
                    ...invoice.customer,
                    _id: undefined
                } : undefined,
                items: Array.isArray(invoice.items) ? invoice.items.map(item => ({
                    ...item,
                    _id: undefined
                })) : []
            });
            res.status(200).json(invoices.map(normalizeInvoice));
        } catch (error) {
            console.error('Error fetching invoices:', error);
            res.status(500).json({ error: 'Failed to fetch invoices' });
        }
    }
}

module.exports = new InvoiceController();