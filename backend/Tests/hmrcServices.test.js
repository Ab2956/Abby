require('dotenv').config();
const authServices = require('../src/services/authServices');
const HttpClient = require('../src/services/httpClient');

describe('Test hmrcServices', ()=>{
    it('Can get token data', ()=>{
        const codeData = authServices.createUrl();
        console.log('authorize url:', codeData)
        const code = codeData.data;

        const response = token.getTokenData(code);
        console.log(response.data);
        return response.data;
    
    });
    it('Can get obligations.',()=>{

    });
})