const dataHandler = require('../database/dataHandler');

class InvoiceServices {


    async getInoiceById(id) {

    }

    async addInvoice(invoice) {
        return await dataHandler.addInvoice(invoice);
    }

} module.exports = new InvoiceServices();