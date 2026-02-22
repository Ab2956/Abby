require('dotenv').config();
const HmrcService = require('../src/services/hmrcServices');
const authServices = require('../src/services/authServices');
const userServices = require('../src/services/userServices');
const db = require('../src/database/connectDB');


describe('Test Obligations', () => {
    afterAll(async () => {
        await db.closeConnection();
    });

    const userId = "68fa2057b845e279d8dc41a9";
    const vrn = process.env.TEST_VRN || '125354193';
    const from = process.env.HMRC_OBLIGATIONS_FROM;
    const to = process.env.HMRC_OBLIGATIONS_TO;
    const status = process.env.HMRC_OBLIGATIONS_STATUS || 'O';

    it('can get obligations from HMRC using refresh token', async () => {
    
        const refreshToken = await userServices.getRefreshToken(userId);
        if (!refreshToken) {
            console.warn('No refresh token found');
            return;
        }

        const tokenData = await authServices.getRefreshToken(refreshToken);
        const accessToken = tokenData.access_token;
        await userServices.updateRefreshToken(userId, tokenData.refresh_token, tokenData.expires_in);

        const hmrcService = new HmrcService(accessToken);
        const obligations = await hmrcService.getObligations(vrn, from, to, status);

        expect(obligations).toBeDefined();
        if (obligations && Object.prototype.hasOwnProperty.call(obligations, 'obligations')) {
            expect(Array.isArray(obligations.obligations)).toBe(true);
        }
        console.log('Obligations:', JSON.stringify(obligations, null, 2));
    });
});