require('dotenv').config();
const OAuthClient = require('../utils/oauthClient');

module.exports = {

    createUrl: () => {
        const redirectUri = process.env.REDIRECT_URI;
        const client_id = process.env.CLIENT_ID;
        const scopes = [
            "read:vat",
            "write:vat",
            "read:self-assessment",
            "write:self-assessment"
        ];
        const scope = encodeURIComponent(scopes.join(' '));

        return `https://test-api.service.hmrc.gov.uk/oauth/authorize?response_type=code` +
            `&client_id=${client_id}` +
            `&redirect_uri=${encodeURIComponent(redirectUri)}` +
            `&scope=${scope}`;
    },

    getTokenData: async(code) => {
        const client = new OAuthClient("https://test-api.service.hmrc.gov.uk");
        try {
            const params = new URLSearchParams({
                client_secret: process.env.CLIENT_SECRET,
                client_id: process.env.CLIENT_ID,
                grant_type: "authorization_code",
                redirect_uri: process.env.REDIRECT_URI,
                code

            });

            return await client.post("/oauth/token", params, {
                'Content-Type': 'application/x-www-form-urlencoded'
            });

        } catch (error) {
            throw new Error('Failed: exchange token');
        }
    },

    getRefreshToken: async(refreshToken) => {
        const client = new OAuthClient("https://test-api.service.hmrc.gov.uk");
        const params = new URLSearchParams({
            grant_type: "refresh_token",
            client_id: CLIENT_ID,
            client_secret: CLIENT_SECRET,
            refresh_token: refreshToken
        });
        return await client.get("/oauth/token", params, {
            'Content-Type': 'application/x-www-form-urlencoded'
        });
    },

};