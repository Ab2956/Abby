const InoviceSchema = require("../models/InvoiceModel");
const PdfParser = require("../invoiceSystem/pdfParser");
const ImageParser = require("../invoiceSystem/imageParser");
const userServices = require("../services/userServices");
const pdfParser = new PdfParser();
const imageParser = new ImageParser();

class InvoiceController {
    constructor() {}

    /**
     * Handle file upload
     * @param {Object} file - File object from multer middleware
     * @returns {Promise<Object>} Upload result
     */
    async handleUpload(file) {

        try {
            if (!file || !file.buffer) {
                throw new Error('No file provided');
            }
            if(file.mimetype == "application/pdf") {
                const parsedFile = await pdfParser.parseFile();
            } else if(file.mimetype.startsWith("image/")) {
                const parsedFile = await imageParser.parseFile();
            }
            
            new InvoiceSchema = {
               // parsed file to be formatted to schema
            };

             await userServices.addInvoice(fileToAdd);

            // TODO: Implement invoice parsing logic here using strategy pattern
            // if file is PDF, use PDFParser and if file is image, use ImageParser
            // add parsed format into the users database collection

            return {};
        } catch (error) {
            throw new Error(`File upload failed: ${error.message}`);
        }
    }
}

module.exports = InvoiceController;