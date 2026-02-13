require('dotenv').config();
const HmrcService = require('../src/services/hmrcServices');

describe('Test Obligations', () => {
    const accessToken = process.env.HMRC_ACCESS_TOKEN;
    const vrn = 125354193;
    const from = process.env.HMRC_OBLIGATIONS_FROM;
    const to = process.env.HMRC_OBLIGATIONS_TO;
    const status = process.env.HMRC_OBLIGATIONS_STATUS || 'O';

    const testFn = accessToken && vrn ? it : it.skip;

    testFn('can get obligations from HMRC', async () => {
        const hmrcService = new HmrcService(accessToken);
        const obligations = await hmrcService.getObligations(vrn, from, to, status);

        expect(obligations).toBeDefined();
        if (obligations && Object.prototype.hasOwnProperty.call(obligations, 'obligations')) {
            expect(Array.isArray(obligations.obligations)).toBe(true);
        }
    });
});