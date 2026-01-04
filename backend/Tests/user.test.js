require('dotenv').config();
const db = require('../src/database/connectDB');
const userServices = require('../src/services/userServices');

let usersCollection;

describe('User Tests', () => {
    beforeAll(async() => {

        await db.createConnection();
        usersCollection = await db.getCollection('users');

    });

    afterEach(async () => {
        // cleanup test user if it was created
        try {
            await usersCollection.deleteOne({ email: 'helloworld@gmail.com' });
        } catch (err) {
            // ignore cleanup errors
        }
    });

    afterAll(async() => {
        await db.closeConnection();
    });

    it('can get user', async() => {
            const users = await usersCollection.find({}).toArray();

            console.log('Users: ', users);
            expect(users).toBeDefined();

        }),
        it('can throw error for existing email', async() => {
            const email = "adambrows@gmail.com";
            const password = "hello";
            const token_expiration = '';
            const refresh_token = '';

            const newUser = {
                email: email,
                password: password,
                refresh_token: refresh_token,
                token_expiration: token_expiration,

            };
            await expect(userServices.addUser(newUser)).rejects.toThrow("email already exists");
        }),
        it('can create user with email and password', async() => {
            const email = "helloworld@gmail.com";
            const password = "password";

            const newUser = {
                email: email,
                password: password,

            }
            await userServices.addUser(newUser);

        })
});