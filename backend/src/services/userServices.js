const bcrypt = require('bcrypt');
const databaseHandler = require('../database/dataHandler');
const tokenEncryption = require('../utils/tokenEncryption');
const e = require('express');
const { encryptToken, decryptToken } = tokenEncryption;

class UserServices {
    constructor() {}

    async addUser(userData) {

        const { email, password,vrn, refresh_token = '', token_expiration = '' } = userData;
        const hashed_password = await bcrypt.hash(password, 10);
        const encrypted_vrn = await encryptToken(vrn);
        try {
            if (!userData.email || !userData.password || !userData.vrn) {
                throw new Error("missing email or password or vrn");
            }
            const existing = await databaseHandler.findUser({ email });
            if (existing) {
                throw new Error("email already exists");
            }
            const user = ({
                email,
                password: hashed_password,
                vrn: encrypted_vrn,
                refresh_token,
                token_expiration,
            })

            return await databaseHandler.addUser(user);

        } catch (error) {
            console.log("AddUser", error);
            throw error;
        }
    }

    async getUserByEmail(email) {
        try {
            return await databaseHandler.findUser({ email });
        } catch (error) {
            console.log("GetUserByEmail", error);
            throw error;
        }
    }
    
    async updateUser(userId, updateData) {
        try {
            return await databaseHandler.updateUser(userId, updateData);
        } catch (error) {
            console.log("UpdateUser", error);
            throw error;
        }
    }
    async getRefreshToken(userId) {
        try {
            return await databaseHandler.getRefreshToken(userId);
        } catch (error) {
            console.log("GetRefreshToken", error);
            throw error;
        }
    }
    async updateRefreshToken(userId, refreshToken, expiresIn) {
        try {
            const encryptedToken = await encryptToken(refreshToken);
            return await databaseHandler.updateRefreshToken(userId, encryptedToken, expiresIn);
        } catch (error) {
            console.log("UpdateRefreshToken", error);
            throw error;
        }
    }
}

module.exports = new UserServices();