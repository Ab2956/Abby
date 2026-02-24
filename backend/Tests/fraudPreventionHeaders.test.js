require("dotenv").config();

const HttpClient = require('../src/utils/httpClient');
const HmrcService = require('../src/services/hmrcServices');
const axios = require('axios');
const authServices = require('../src/services/authServices');
const userServices = require('../src/services/userServices');
const db = require('../src/database/connectDB');

describe('Test HMRC API headers', () => {
    afterAll(async () => {
        await db.closeConnection();
    });
    
    const refreshToken = process.env.TEST_REFRESH_TOKEN || process.env.HMRC_REFRESH_TOKEN;
    const vrn = process.env.TEST_VRN || '125354193';
    const from = process.env.HMRC_OBLIGATIONS_FROM;
    const to = process.env.HMRC_OBLIGATIONS_TO;
    const status = process.env.HMRC_OBLIGATIONS_STATUS || 'O';

    it('should include correct headers', async () => {

        const userId = "68fa2057b845e279d8dc41a9";
        const refreshToken = await userServices.getRefreshToken(userId);
        const tokenData = await authServices.getRefreshToken(refreshToken);
        const accessToken = tokenData.access_token;
        await userServices.updateRefreshToken(userId, tokenData.refresh_token, tokenData.expires_in);

        const deviceInfo = {
            "Gov-Client-Connection-Method": "MOBILE_APP_VIA_SERVER",
            "Gov-Client-Device-ID": "beec798b-b366-47fa-b1f8-92cede14a1ce",
            "Gov-Client-Local-IPs": "fc00%3A%3A,10.1.2.3+00:00",
            "Gov-Client-Local-IPs-Timestamp": "2020-09-21T14:30:05.123Z",
            "Gov-Client-Public-IP": "198.51.100.0",
            "Gov-Client-Public-IP-Timestamp": "2020-09-21T14:30:05.123Z",
            "Gov-Client-Public-Port": "12345",
            "Gov-Client-Screens": "width=375&height=812&scaling-factor=2&colour-depth=32",
            "Gov-Client-Timezone": "UTC+00:00",
            "Gov-Client-User-Agent": "os-family=iOS&os-version=13.3.1&device-manufacturer=Apple&device-model=iPhone12%2C3",
            "Gov-Client-User-IDs": "my-application=alice123",
            "Gov-Client-Window-Size": "width=375&height=812",
            "Gov-Vendor-Forwarded": "by=203.0.113.6&for=198.51.100.0",
            "Gov-Vendor-License-IDs": "my-licensed-software=8D7963490527D33716835EE7C195516D5E562E03B224E9B359836466EE40CDE1",
            "Gov-Vendor-Product-Name": "Product%20Name",
            "Gov-Vendor-Public-IP": "203.0.113.6",
            "Gov-Vendor-Version": "my-mobile-app=2.2.2&my-serverside-code=v3.8",

        };
        const response = await axios.get(
            'https://test-api.service.hmrc.gov.uk/test/fraud-prevention-headers/validate',
            {
                headers: {
                    Authorization: `Bearer ${accessToken}`,
                    Accept: 'application/vnd.hmrc.1.0+json',
                    ...deviceInfo,
                },
            }
        );
        console.log('Validation result:', JSON.stringify(response.data, null, 2));

        expect(response.status).toBe(200);

    });
}, 30000);

