const bcrypt = require('bcrypt');
const userDataHandler = require('../database/userDataHandler');
const tokenEncryption = require('../utils/tokenEncryption');
const authServices = require('./authServices');
const e = require('express');
const { encryptToken, decryptToken } = tokenEncryption;

class UserServices {
    constructor() {}

    async addUser(userData) {

        const { email, password, vrn, refresh_token = '', token_expiration = '' } = userData;
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
    async updateVrn(userId, vrn) {
        try {
            const encryptedVrn = await encryptToken(vrn);
            return await userDataHandler.updateVrn(userId, encryptedVrn);
        } catch (error) {
            console.log("UpdateVrn", error);
            throw error;
        }
    }
    async getVrn(userId) {
        try {
            const user = await userDataHandler.getUserById(userId);
            if (user && user.vrn) {
                const vrn = await decryptToken(user.vrn);
                return vrn;
            }
            return null;
        } catch (error) {
            console.log("GetVrn", error);
            throw error;
        }
    }
    async isConnectedToHMRC(userId) {
        try {
            return await userDataHandler.isConnectedToHMRC(userId);
        } catch (error) {
            console.log("IsConnectedToHMRC", error);
            throw error;
        }
    }

    async getValidAccessToken(userId, forceRefresh = false) {
        try {
            // Check if we have a cached access token that hasn't expired
            if (!forceRefresh) {
                const tokenInfo = await userDataHandler.getAccessToken(userId);
                if (tokenInfo && tokenInfo.access_token && tokenInfo.token_expiration) {
                    const bufferMs = 60 * 1000; // 1 minute buffer before expiry
                    if (tokenInfo.token_expiration > (Date.now() + bufferMs)) {
                        // Token is still valid, decrypt and return it
                        const accessToken = await decryptToken(tokenInfo.access_token);
                        return accessToken;
                    }
                }
            }

            // Token expired, missing, or force refresh requested — refresh it
            const refreshToken = await this.getRefreshToken(userId);
            if (!refreshToken) {
                throw new Error('No refresh token found, please reconnect to HMRC');
            }

            const tokenData = await authServices.getRefreshToken(refreshToken);
            const { access_token, refresh_token, expires_in } = tokenData;

            // Store the new tokens (encrypted) in the database
            const encryptedAccess = await encryptToken(access_token);
            const encryptedRefresh = await encryptToken(refresh_token);
            await userDataHandler.updateAccessToken(userId, encryptedAccess, encryptedRefresh, expires_in);

            return access_token;
        } catch (error) {
            console.log("GetValidAccessToken", error);
            throw error;
        }
    }

}

module.exports = new UserServices();