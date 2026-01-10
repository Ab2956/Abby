const User = require('../models/UserSchema');
const db = require('../database/connectDB');
const bcrypt = require('bcrypt');
const databaseHandler = require('../database/dataHandler');

class UserServices {
    constructor() {}

    async addUser(userData) {

        const { email, password, refresh_token = '', token_expiration = '' } = userData;
        const hashed_password = await bcrypt.hash(password, 10);
        try {
            if (!userData.email || !userData.password) {
                throw new Error("missing email or password");
            }
            const existing = await databaseHandler.findUser({ email });
            if (existing) {
                throw new Error("email already exists");
            }
            const user = ({
                email,
                password: hashed_password,
                refresh_token,
                token_expiration,
            })

            return await databaseHandler.addUser(user);

        } catch (error) {
            console.log("AddUser", error);
            throw error;
        }
    }

}

module.exports = new UserServices;