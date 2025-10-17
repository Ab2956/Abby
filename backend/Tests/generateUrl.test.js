require('dotenv').config();
const authServices = require('../src/services/authServices');
const { url, createUrl } = require('../src/services/authServices');

jest.mock('axios');

beforeAll(()=>{

    
    process.env.REDIRECT_URI = 'http://localhost:3000/callback';
    console.log('CLIENT_ID:', process.env.CLIENT_ID);
    console.log('REDIRECT_URI:', process.env.REDIRECT_URI);
});

describe('Test generates url', () => {
    it('generates url',  () => {
        const expected = `https://test-api.service.hmrc.gov.uk/oauth/authorize?response_type=code&client_id=${process.env.CLIENT_ID}&redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Fcallback&scope=read%3Avat%20write%3Avat`;
        const generated = createUrl(); 

        console.log('CLIENT_ID:', process.env.CLIENT_ID);
        console.log('REDIRECT_URI:', process.env.REDIRECT_URI);
        
        
        console.log("Generated: ", generated);
        console.log("Expected: ",expected);

        console.log(authServices.createUrl());

        expect(generated).toBe(expected);
       
    })
   
})