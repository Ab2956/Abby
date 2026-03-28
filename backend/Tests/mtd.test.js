require('dotenv').config();
const mtdServices = require('../src/services/mtdServices');
const userServices = require('../src/services/userServices');
HmrcService = require('../src/services/hmrcServices');


describe("Making Tax Digital Tests", () => {
    test("should get vat obligations", async () => {

    }   
    );
    test("should submit vat return", async () => {  
        
    });
    test("should get total vat", async () => {
        
    });
    test ("should submit tax quartly with hardcoded test businessId", async () => {

        const accessToken =  await userServices.getValidAccessToken("68fa2057b845e279d8dc41a9", true);
        const fraudHeaders = {
            "Gov-Client-Connection-Method": "MOBILE_APP_VIA_SERVER",
            "Gov-Client-Device-ID": "test-device-id",
            "Gov-Client-User-IDs": "Abby=test-user",
            "Gov-Vendor-Product-Name": "Abby",
            "Gov-Vendor-Version": "Abby=1.0.0",
        };

        const hmrcService = new HmrcService(accessToken, fraudHeaders);
        const nino = 'WW812708C';
        const businessId = 'XBIS12345678901';
        
        const result = await hmrcService.submitQuarterlyData(nino, businessId, 1, "2023-24", {
            "turnover": 100000,
            "others": 5000,
            "taxTakenOffTradingIncome": 2000,
        }
        );
        console.log("Submission result:", result);


    });

});