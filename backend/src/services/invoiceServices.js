const dataHandler = require('../database/dataHandler');

class InvoiceServices {


    async getInoiceById(id) {

    }

    async addInvoice(userId, invoice) {
        return await dataHandler.addInvoice(userId, invoice);
    }
    
    async getInvoices(userId = null) {
        return await dataHandler.getInvoices(userId);
    }
    
    async getVatTotal(userId) {
        return await dataHandler.getVatTotalbyUserId(userId);
    }
    
    async getInvoiceCollection() {
        return await dataHandler.getInvoiceCollection();
    }

} module.exports = new InvoiceServices();