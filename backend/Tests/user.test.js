require('dotenv').config();
const db = require('../src/database/connectDB');
const userServices = require('../src/services/userServices');
const mongoose = require('mongoose');
const bcrypt = require("bcrypt");

describe('User Tests', () => {
    beforeAll(async() => {
        await db.connectDB();
        usersCollection = await db.getCollection('users');

    });

    afterAll(async() => {
        await mongoose.connection.close();
    });

    it('can get user', async() => {
            const users = await usersCollection.find({}).toArray();

            console.log('Users: ', users);
            expect(users).toBeDefined();

        }),
        it('can create a user', async() => {
            const email = "adambrows@gmail.com";
            const password = "hello";
            const hashedpass = await bcrypt.hash(password, 10);
            const token_expiration = '';
            const refresh_token = '';

            const newUser = {
                email: email,
                password: hashedpass,
                refresh_token: refresh_token,
                token_expiration: token_expiration,

            };
            const addUser = await userServices.addUser(newUser);
            console.log("created user: ", addUser);
            expect(addUser).toBeDefined();
        })
});