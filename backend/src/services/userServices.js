const bcrypt = require('bcrypt');
const databaseHandler = require('../database/dataHandler');

class UserServices {
    constructor() {}

    async addUser(userData) {

        const { email, password,vrn, refresh_token = '', token_expiration = '' } = userData;
        const hashed_password = await bcrypt.hash(password, 10);
        const hashed_vrn = await bcrypt.hash(vrn,10);
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
                vrn: hashed_vrn,
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
}

module.exports = new UserServices;