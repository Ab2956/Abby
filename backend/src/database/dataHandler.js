const db = require('../database/connectDB');
const { ObjectId } = require('mongodb');
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
        return await userCollection.updateOne(
            { _id: new ObjectId(userId)},
            { $set: updateData }
        );
    }
    async addInvoice(userId, invoiceData) {
        const userCollection = await this.getUsers();
        return await userCollection.updateOne(
            { _id: new ObjectId(userId) },
            { $push: { invoices: invoiceData } }
        );
    }
}
module.exports = new DatabaseHandler();