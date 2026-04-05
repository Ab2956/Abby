require('dotenv').config();
const authServices = require('../src/services/authServices');
const userServices = require('../src/services/userServices');
const HmrcService = require('../src/services/hmrcServices');
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
    it('Can get refresh token data', async() => {
        const refreshToken = await userServices.getRefreshToken("68fa2057b845e279d8dc41a9");

        console.log("token data: " + refreshToken);
        return refreshToken;
    });
    // it('Can get business details', async () => {
    //     const accessToken = await userServices.getValidAccessToken("68fa2057b845e279d8dc41a9", true);
    //     const fraudHeaders = {
    //         "Gov-Client-Connection-Method": "MOBILE_APP_VIA_SERVER",
    //         "Gov-Client-Device-ID": "test-device-id",
    //         "Gov-Client-User-IDs": "Abby=test-user",
    //         "Gov-Vendor-Product-Name": "Abby",
    //         "Gov-Vendor-Version": "Abby=1.0.0",
    //     };
    //     const extraHeaders = {
    //         ...fraudHeaders,
    //         'Gov-Test-Scenario': 'BUSINESS_DETAILS_FOUND'
    //         };
    //         const hmrcService = new HmrcService(accessToken, {
    //             ...extraHeaders,
    //             'Gov-Test-Scenario': 'NOT_FOUND'
    //         });

    //     try {
    //         const response = await hmrcService.getBusinessId('WW812708C');
    //         console.log("Business Details:", response);
    //     } catch (error) {
    //         console.log("Error body:", JSON.stringify(error.response?.data));
    //         throw error;
    //     }
    // });
})