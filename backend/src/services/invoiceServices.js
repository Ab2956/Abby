const invoiceDataHandler = require('../database/invoiceDataHandler');

class InvoiceServices {

    // Service functions for invoice operations

    async addInvoice(userId, invoice) {
        return await invoiceDataHandler.addInvoice(userId, invoice);
    }
    
    async getInvoices(userId = null) {
        return await invoiceDataHandler.getInvoices(userId);
    }
    
    async getVatTotal(userId) {
        return await invoiceDataHandler.getVatTotalbyUserId(userId);
    }
    
    async getInvoiceCollection() {
        return await invoiceDataHandler.getInvoiceCollection();
    }
    async deleteInvoice(invoiceId) {
        return await invoiceDataHandler.deleteInvoice(invoiceId);
    }

} module.exports = new InvoiceServices();