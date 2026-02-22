const db = require('../database/connectDB');
const { ObjectId } = require('mongodb');
const { decryptToken } = require('../utils/tokenEncryption');
// data layer for database functions 
class DatabaseHandler {
    constructor() {};

    async getUsers() {
        return await db.getCollection('users');
    }
    async findUser(query) {
        const userCollection = await this.getUsers();
        return await userCollection.findOne(query);
    }

    async addUser(user) {
        const userCollection = await this.getUsers();
        return await userCollection.insertOne(user);
    }
    async updateUser(userId, updateData) {
        const userCollection = await this.getUsers();
        return await userCollection.updateOne({ _id: new ObjectId(userId) }, { $set: updateData });
    }
    async getRefreshToken(userId) {
            const userCollection = await this.getUsers();
            const user = await userCollection.findOne({ _id: new ObjectId(userId) });
            if (user && user.refresh_token) {
                // Decrypt the token before returning
                const refreshToken = decryptToken(user.refresh_token);
                return refreshToken;
            }
            return null;
        }
    async updateRefreshToken(userId, encryptedToken, expiresIn) {
        const userCollection = await this.getUsers();
        return await userCollection.updateOne({ _id: new ObjectId(userId) }, 
        { $set: { refresh_token: encryptedToken, token_expiration: Date.now() + (expiresIn * 1000) } });
    }
        //Invoice functions

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
        //Bookkeeping functions
    async getRecipts() {
        return await db.getCollection('recipts');
    }
    async getReciptsByUserId(userId = null) {
        const reciptCollection = await this.getRecipts();
        const query = userId ? { userId: new ObjectId(userId) } : {};
        return await reciptCollection.find(query).toArray();
    }
    async addRecpit(userId, reciptData) {
        const reciptCollection = await this.getRecipts();
        const recpit = {
            ...reciptData,
            userId: new ObjectId(userId),
            created_at: new Date()
        }
        return await reciptCollection.insertOne(recpit);
    }
    async deleteRecipt(reciptId) {
        const reciptCollection = await this.getRecipts();
        return await reciptCollection.deleteOne({ _id: new ObjectId(reciptId) });
    }
}
module.exports = new DatabaseHandler();