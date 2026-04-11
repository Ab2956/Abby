const db = require('./connectDB');
const { ObjectId } = require('mongodb');

class invoiceDataHandler {
    //Data handler to get invoice data from the database or upload data

    constructor() {
    }   

    // helper function to get the collection
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

    async getAllUserInvoices(userId) {
        const invoiceCollection = await this.getInvoiceCollection();
        return await invoiceCollection.find({ userId: new ObjectId(userId) }).toArray();
    }
    
    async getAllVatAmountsByUserId(userId) {
        const invoiceCollection = await this.getInvoiceCollection();
        const pipeline = [
            { $match: { userId: new ObjectId(userId) } },
            { $group: { _id: null, totalVat: { $sum: "$vat_amount" } } }
        ];
        const result = await invoiceCollection.aggregate(pipeline).toArray();
        return result.length > 0 ? result[0].totalVat : 0;
    }
}

module.exports = new invoiceDataHandler();