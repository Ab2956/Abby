require('dotenv').config();
const axios = require('axios');
const OAuthClient = require('../utils/oauthClient');
const client = new OAuthClient("https://test-api.service.hmrc.gov.uk");
const HMRC_AUTH_URL = "https://test-api.service.hmrc.gov.uk/oauth/authorize";

module.exports = {

    createUrl: () => {
        const redirectUri = process.env.REDIRECT_URI;
        const client_id = process.env.CLIENT_ID;
        const scope = encodeURIComponent("read:vat write:vat");

        return `${HMRC_AUTH_URL}?response_type=code` +
                `&client_id=${client_id}` +
                `&redirect_uri=${encodeURIComponent(redirectUri)}` +
                `&scope=${scope}`;
    },

    getTokenData: async (code) => { 
        try{
            const params = new URLSearchParams({
                client_secret: process.env.CLIENT_SECRET,
                client_id: process.env.CLIENT_ID,
                grant_type: "authorization_code",
                redirect_uri: process.env.REDIRECT_URI,
                code

            });

            return await client.post("/oauth/token",params,{ 'Content-Type': 'application/x-www-form-urlencoded' 
            });
            
        } catch (error) {
            throw new Error('Failed: exchange token');
        }
    },

    refreshAccesToken: async (refreshToken) =>{
        const params = new URLSearchParams({
            grant_type: "refresh_token",
            client_id: CLIENT_ID,
            client_secret: CLIENT_SECRET,
            refresh_token: refreshToken
        });
        return await client.get("/oauth/token",params,{ 'Content-Type': 'application/x-www-form-urlencoded' 
        });
    },
};
