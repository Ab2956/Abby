const InoviceSchema = require("../models/InvoiceModel");
const {PdfParser} = require("../invoiceSystem/pdfParser");
const {ImageParser} = require("../invoiceSystem/imageParser");
const invoiceServices = require("../services/invoiceServices");

const pdfParser = new PdfParser();
const imageParser = new ImageParser();

class InvoiceController {
    constructor() {}

    async handleUpload(file) {

        try {
            if (!file || !file.buffer) {
                throw new Error('No file provided');
            }
            if (file.mimetype == "application/pdf") {
                const parsedFile = await pdfParser.parseFile(file.buffer);
                await invoiceServices.addInvoice(parsedFile);
                return { success: true, message: "Invoice uploaded successfully", invoice: parsedFile };

            } else if (file.mimetype.startsWith("image/")) {
                const parsedFile = await imageParser.parseFile(file.buffer);
                await invoiceServices.addInvoice(parsedFile);
                return { success: true, message: "Invoice uploaded successfully", invoice: parsedFile };

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
            res.status(200).json(invoices);
        } catch (error) {
            console.error('Error fetching invoices:', error);
            res.status(500).json({ error: 'Failed to fetch invoices' });
        }
    }
}

module.exports = new InvoiceController();