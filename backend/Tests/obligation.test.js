require('dotenv').config();
const HmrcService = require('../src/services/hmrcServices');
const authServices = require('../src/services/authServices');

describe('Test Obligations', () => {
    const accessToken = process.env.TEST_ACCESS_TOKEN;
    const refreshToken = process.env.TEST_REFRESH_TOKEN || process.env.HMRC_REFRESH_TOKEN;
    const vrn = process.env.TEST_VRN || '125354193';
    const from = process.env.HMRC_OBLIGATIONS_FROM;
    const to = process.env.HMRC_OBLIGATIONS_TO;
    const status = process.env.HMRC_OBLIGATIONS_STATUS || 'O';

    const testFn = (accessToken || refreshToken) && vrn ? it : it.skip;

    testFn('can refresh token and get obligations from HMRC', async () => {
        let token = accessToken;
        if (!token && refreshToken) {
            const tokenData = await authServices.getRefreshToken(refreshToken);
            token = tokenData.access_token;
        }
        const hmrcService = new HmrcService(token);
        const obligations = await hmrcService.getObligations(vrn, from, to, status);

        expect(obligations).toBeDefined();
        if (obligations && Object.prototype.hasOwnProperty.call(obligations, 'obligations')) {
            expect(Array.isArray(obligations.obligations)).toBe(true);
        }
    });
});