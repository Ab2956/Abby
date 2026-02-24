const dataHandler = require('../database/dataHandler');
const invoiceDataHandler = require('../database/invoiceDataHandler');

class InvoiceServices {


    async getInoiceById(id) {

    }

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

} module.exports = new InvoiceServices();