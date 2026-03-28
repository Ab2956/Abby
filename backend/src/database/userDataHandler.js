const db = require('./connectDB');
const { ObjectId } = require('mongodb');
const { decryptToken } = require('../utils/tokenEncryption');

class userDataHandler {
    constructor() {}
    async getUsers() {
        return await db.getCollection('users');
    }
    async findUser(query) {
        const userCollection = await this.getUsers();
        return await userCollection.findOne(query);
    }
    async getUserById(userId) {
        const userCollection = await this.getUsers();
        return await userCollection.findOne({ _id: new ObjectId(userId) });
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
        return await userCollection.updateOne({ _id: new ObjectId(userId) }, { $set: { refresh_token: encryptedToken, token_expiration: Date.now() + (expiresIn * 1000) } });
    }
    async getAccessToken(userId) {
        const userCollection = await this.getUsers();
        const user = await userCollection.findOne({ _id: new ObjectId(userId) });
        if (user && user.access_token && user.token_expiration) {
            return {
                access_token: user.access_token,
                token_expiration: user.token_expiration
            };
        }
        return null;
    }
    async updateAccessToken(userId, encryptedAccessToken, encryptedRefreshToken, expiresIn) {
        const userCollection = await this.getUsers();
        return await userCollection.updateOne({ _id: new ObjectId(userId) }, {
            $set: {
                access_token: encryptedAccessToken,
                refresh_token: encryptedRefreshToken,
                token_expiration: Date.now() + (expiresIn * 1000)
            }
        });
    }
    async updateVrn(userId, encryptedVrn) {
        const userCollection = await this.getUsers();
        return await userCollection.updateOne({ _id: new ObjectId(userId) }, { $set: { vrn: encryptedVrn } });
    }
    async getVrn(userId) {
        const userCollection = await this.getUsers();
        const user = await userCollection.findOne({ _id: new ObjectId(userId) });
        if (user && user.vrn) {
            const vrn = decryptToken(user.vrn);
            return vrn;
        }
        return null;
    }
    async isConnectedToHMRC(userId) {
        const userCollection = await this.getUsers();
        const user = await userCollection.findOne({ _id: new ObjectId(userId) });
        return user ? !!user.hmrc_connected : false;
    }
    async updateNino(userId, encryptedNino) {
        const userCollection = await this.getUsers();
        return await userCollection.updateOne({ _id: new ObjectId(userId) }, { $set: { nino: encryptedNino } });
    }
    async getNino(userId) {
        const userCollection = await this.getUsers();
        const user = await userCollection.findOne({ _id: new ObjectId(userId) });
        if (user && user.nino) {
            const nino = decryptToken(user.nino);
            return nino;
        }        return null;
    }
}
module.exports = new userDataHandler();