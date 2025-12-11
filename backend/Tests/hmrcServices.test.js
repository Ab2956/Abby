require('dotenv').config();
const authServices = require('../src/services/authServices');
const HttpClient = require('../src/utils/httpClient');

describe('Test hmrcServices', () => {
    it('Can get token data', () => {
        const codeData = authServices.createUrl();
        console.log('authorize url:', codeData)
        const code = codeData.data;
        const token = authServices.getTokenData(code);

        console.log(token.data);
        return token.data;

    });
    it('Can get obligations.', () => {

    });
})