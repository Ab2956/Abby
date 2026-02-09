const dataHandler = require('../dataHandler/dataHandler');

class InvoiceServices {


    async getInoiceById(id) {

    }

    async addInvoice(invoice) {
        return await dataHandler.addInvoice(invoice);
    }

}