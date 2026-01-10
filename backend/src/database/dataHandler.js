const db = require('../database/connectDB');
const { get } = require('../models/UserSchema');

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

}
module.exports = new DatabaseHandler;