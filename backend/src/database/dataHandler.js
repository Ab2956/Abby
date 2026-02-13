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
            return decryptToken(user.refresh_token);
        }
        return null;
    }
    //Invoice functions
    async getInvoices() {
        return await db.getCollection('invoices');
    }

    async addInvoice(userId, invoiceData) {
        const invoiceCollection = await this.getInvoices();
        return await invoiceCollection.updateOne({ _id: new ObjectId(userId) }, { $push: { invoices: invoiceData } });
    }
    async getVatTotalbyUserId(userId) {
    
    }
    //Bookkeeping functions
    async getRecipts() {
        return await db.getCollection('recipts');
    }
    async addRecpit(userId, reciptData) {
        const reciptCollection = await this.getRecipts();
        return await reciptCollection.updateOne({ _id: new ObjectId(userId) }, { $push: { recipts: reciptData } });
    }
}
module.exports = new DatabaseHandler();