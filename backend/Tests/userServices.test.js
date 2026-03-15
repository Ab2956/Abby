require('dotenv').config();
const db = require('../src/database/connectDB');
const userServices = require('../src/services/userServices');

let usersCollection;

describe('User Tests', () => {
    beforeAll(async() => {

        await db.createConnection();
        usersCollection = await db.getCollection('users');

    });

    afterEach(async() => {
        try {
            await usersCollection.deleteOne({ email: 'helloworld@gmail.com' });
        } catch (err) {

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
            const vrn = "AB123456C";
            const token_expiration = '';
            const refresh_token = '';

            const newUser = {
                email: email,
                password: password,
                vrn: vrn,
                refresh_token: refresh_token,
                token_expiration: token_expiration,

            };
            await expect(userServices.addUser(newUser)).rejects.toThrow("email already exists");
        }),
        it('can create user with email and password', async() => {
            const email = "helloworld@gmail.com";
            const password = "password";
            const vrn = "XY987654Z";

            const newUser = {
                email: email,
                password: password,
                vrn: vrn

            }
            await userServices.addUser(newUser);

        }),
        it("can get refresh token for user", async() => {
            const userId = "68fa2057b845e279d8dc41a9";
            const refreshToken = await userServices.getRefreshToken(userId);
            console.log("Refresh Token:", refreshToken);
            expect(refreshToken).not.toBeNull();
        })
    it("can add vrn", async() => {
        const userId = "68fa2057b845e279d8dc41a9";
        const vrn = "125354193";
        await userServices.updateVrn(userId, vrn);
        const updatedUser = await userServices.getUserByEmail("romwan.newton@example.com");
        expect(updatedUser.vrn).toBeDefined();
    });
    it("can get vrn", async() => {
        const userId = "68fa2057b845e279d8dc41a9";
        const vrn = await userServices.getVrn(userId);
        console.log("VRN:", vrn);
        expect(vrn).not.toBeNull();
    });
    it("can check if user is connected to HMRC", async() => {
        const userId = "68fa2057b845e279d8dc41a9";
        const isConnected = await userServices.isConnectedToHMRC(userId);
        console.log("Is Connected to HMRC:", isConnected);
        expect(isConnected).toBe(true);
    });
});