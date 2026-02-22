require('dotenv').config();
const authServices = require('../src/services/authServices');
const userServices = require('../src/services/userServices');
const HttpClient = require('../src/utils/httpClient');
const db = require('../src/database/connectDB');

describe('Test hmrcServices', () => {
    afterAll(() => {
        db.closeConnection();
    });
    it('Can generate authorize URL', () => {
        const url = authServices.createUrl('test-state');
        console.log('Authorize URL:', url);
        expect(url).toContain('oauth/authorize');
        expect(url).toContain('response_type=code');
    });
    it('Can get refresh token data', async () => {
        const refreshToken = await userServices.getRefreshToken("68fa2057b845e279d8dc41a9");

        console.log("token data: " + refreshToken);
        return refreshToken;
    });
})