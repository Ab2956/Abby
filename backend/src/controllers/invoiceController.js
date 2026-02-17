const InoviceSchema = require("../models/InvoiceModel");
const PdfParser = require("../invoiceSystem/pdfParser");
const ImageParser = require("../invoiceSystem/imageParser");
const userServices = require("../services/userServices");
const { parse } = require("dotenv");
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
                const parsedFile = await pdfParser.parseFile();
                await userServices.addInvoice(parsedFile);

            } else if (file.mimetype.startsWith("image/")) {
                const parsedFile = await imageParser.parseFile();
                await userServices.addInvoice(parsedFile);

            } else {
                throw new Error('Unsupported file type');
            }

            return {};
        } catch (error) {
            throw new Error(`File upload failed: ${error.message}`);
        }
    }
}

module.exports = InvoiceController;