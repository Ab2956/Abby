const User = require('../models/UserSchema');
const db = require('../database/connectDB');

class UserServices {
    constructor() {}

    async addUser(userData) {
        const userCollection = await db.getCollection('users');
        const { email, password, refresh_token = '', token_expiration = '' } = userData;
        try {
            if (!userData.email || !userData.password) {
                throw new Error("missing email or password");
            }
            const existing = await userCollection.findOne({ email });
            if (existing) {
                throw new Error("email already exists");
            }
            const user = new User({
                email,
                password,
                refresh_token,
                token_expiration,
            })

            return await userCollection.insertOne(user);

        } catch (error) {
            console.log("AddUser", error);
            throw error;
        }
    }
}

module.exports = new UserServices;