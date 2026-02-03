require('dotenv').config();
const ConnectDB = require('../src/database/connectDB');
const dbHandler = require('../src/database/dataHandler');

describe('Database Connection and Data Handler', () => {
    beforeAll(async () => {
        await ConnectDB.createConnection();
    });
    afterAll(async () => {
        await ConnectDB.closeConnection();
    });

    test('Database connection should be established', async () => {
        const db = await ConnectDB.createConnection();
        expect(db).toBeDefined();
    }); 
});