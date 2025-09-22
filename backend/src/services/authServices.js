require('dotenv').config();
const axios = require('axios');

const HMRC_AUTH_URL = "https://test-www.tax.service.gov.uk/oauth/authorize";
const HMRC_TOKEN_URL = "https://test-www.tax.service.gov.uk/oauth/token"; 


module.exports = {

    createUrl: () => {
        const redirectUri = process.env.REDIRECT_URI;
        const client_id = process.env.CLIENT_ID;

        if(!redirectUri || !client_id){
            throw new Error('Missing requirements');
        }

        const scope = encodeURIComponent("read:vat write:vat");

        return `${HMRC_AUTH_URL}?response_type=code` +
                `&client_id=${client_id}` +
                `&redirect_uri=${encodeURIComponent(redirectUri)}` +
                `&scope=${scope}`;
    
    },

    exchangeForToken: async (code) => {
        try {
            const response = await axios.post(HMRC_TOKEN_URL, {
                grant_type: "authorization_code",
                client_id: process.env.CLIENT_ID,
                client_secret:process.env.CLIENT_SECRET,
                redirect_uri: process.env.REDIRECT_URI,
                code

            });

            const {access_token, refresh_token, expires_in} = response.data;
            return response.data;
            //TODO return response data or put into db and access token
            
        } catch (error) {
            throw new Error('Failed: exchange token');
        }

    },

    refreshAccesToken: async (refreshToken) =>{
        const response = await axios.post(HMRC_TOKEN_URL,{
            grant_type: "refresh_token",
            client_id: CLIENT_ID,
            client_secret: CLIENT_SECRET,
            refresh_token: refreshToken
        });
        return response.data;
    },

    getUser: async (access_token) => {
        const response = await axios.get('https://test-api.service.hmrc.gov.uk/individuals/self-assessment/account',{
            headers: {
                Authorization: `Bearer ${accessToken}`,
                Accept: 'application/vnd.hmrc.1.0+json'
            }});

            const userData = response.data.selfAssessment;

            return {
                id: userData.utr,
                name: `${userData.taxpayerName.forename} ${userData.taxpayerName.surname}`,
            };
    }


};
