const bcrypt = require('bcrypt');
const userDataHandler = require('../database/userDataHandler');
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
            const existing = await userDataHandler.findUser({ email });
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

            return await userDataHandler.addUser(user);

        } catch (error) {
            console.log("AddUser", error);
            throw error;
        }
    }

    async getUserByEmail(email) {
        try {
            return await userDataHandler.findUser({ email });
        } catch (error) {
            console.log("GetUserByEmail", error);
            throw error;
        }
    }
    
    async updateUser(userId, updateData) {
        try {
            return await userDataHandler.updateUser(userId, updateData);
        } catch (error) {
            console.log("UpdateUser", error);
            throw error;
        }
    }
    async getRefreshToken(userId) {
        try {
            return await userDataHandler.getRefreshToken(userId);
        } catch (error) {
            console.log("GetRefreshToken", error);
            throw error;
        }
    }
    async updateRefreshToken(userId, refreshToken, expiresIn) {
        try {
            const encryptedToken = await encryptToken(refreshToken);
            return await userDataHandler.updateRefreshToken(userId, encryptedToken, expiresIn);
        } catch (error) {
            console.log("UpdateRefreshToken", error);
            throw error;
        }
    }
}

module.exports = new UserServices();