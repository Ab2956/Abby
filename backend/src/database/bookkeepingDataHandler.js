const db = require('../database/connectDB');
const { ObjectId } = require('mongodb');

class bookkeepingDataHandler {
    constructor() {
    }
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
module.exports = new bookkeepingDataHandler();