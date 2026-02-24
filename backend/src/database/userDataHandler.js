const db = require('./connectDB');
const { ObjectId } = require('mongodb');
const { decryptToken } = require('../utils/tokenEncryption');

class userDataHandler {
    constructor() {
    }   
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
}
module.exports = new userDataHandler();