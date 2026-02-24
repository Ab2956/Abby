const db = require('./connectDB');
const { ObjectId } = require('mongodb');

class invoiceDataHandler {
    constructor() {
    }   

    async getInvoiceCollection() {
        return await db.getCollection('invoices');
    }
    async getInvoices(userId = null) {
        const invoiceCollection = await this.getInvoiceCollection();
        const query = userId ? { userId: new ObjectId(userId) } : {};
        return await invoiceCollection.find(query).toArray();
    }
    
    async addInvoice(userId, invoiceData) {
        const invoiceCollection = await this.getInvoiceCollection();
        const invoice = {
            ...invoiceData,
            userId: new ObjectId(userId),
            created_at: new Date()
        };
        return await invoiceCollection.insertOne(invoice);
    }
    
    async getVatTotalbyUserId(userId) {
        const invoices = await this.getInvoices(userId);
        return invoices.reduce((total, invoice) => total + (invoice.vat_amount || 0), 0);
    }
}
module.exports = new invoiceDataHandler();