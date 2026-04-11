require('dotenv').config();
const userServices = require('../src/services/userServices');
HmrcService = require('../src/services/hmrcServices');
const db = require('../src/database/connectDB');

describe("Making Tax Digital Tests", () => {
    test("should get vat obligations", async() => {

    });

    test("should submit vat return", async() => {

    });

    test("should get total vat", async() => {

    });

    afterAll(async() => {
        await db.closeConnection();
    });
    test("should submit VAT quarterly data", async() => {
        const accessToken =  await userServices.getValidAccessToken("68fa2057b845e279d8dc41a9", true);
        const fraudHeaders = {
            "Gov-Client-Connection-Method": "MOBILE_APP_VIA_SERVER",
            "Gov-Client-Device-ID": "test-device-id",
            "Gov-Client-Local-IPs": "127.0.0.1",
            "Gov-Client-Local-IPs-Timestamp": new Date().toISOString(),
            "Gov-Client-Public-IP": "203.0.113.1",
            "Gov-Client-Public-IP-Timestamp": new Date().toISOString(),
            "Gov-Client-Public-Port": "12345",
            "Gov-Client-Screens": "width=1920&height=1080&colour-depth=24",
            "Gov-Client-Timezone": "UTC+00:00",
            "Gov-Client-User-Agent": "os-family=iOS&os-version=17.0&device-manufacturer=Apple&device-model=iPhone",
            "Gov-Client-User-IDs": "Abby=test-user",
            "Gov-Client-Window-Size": "width=1920&height=1080",
            "Gov-Vendor-Forwarded": "by=127.0.0.1&for=203.0.113.1",
            "Gov-Vendor-License-IDs": "Abby=test-license",
            "Gov-Vendor-Product-Name": "Abby",
            "Gov-Vendor-Public-IP": "127.0.0.1",
            "Gov-Vendor-Version": "Abby=1.0.0",
        };

       const hmrcService = new HmrcService(accessToken, fraudHeaders);
        const vrn = '125354193';
       
        try {
            const result = await hmrcService.submitVATQuarterlyData(vrn, 1, 2023, {
                "periodKey": "21A1",
                "vatDueSales": 100000,
                "vatDueAcquisitions": 5000,
                "totalVatDue": 105000,
                "vatReclaimedCurrPeriod": 2000,
                "netVatDue": 103000,
                "totalValueSalesExVAT": 100000,
                "totalValuePurchasesExVAT": 5000,
                "totalValueGoodsSuppliedExVAT": 0,
                "totalAcquisitionsExVAT": 0,
                "finalised": true
            });
            console.log("Submission result:", result);
           
        } catch (error) {
            console.error("HMRC Error Status:", error.response?.status);
            console.error("HMRC Error Body:", JSON.stringify(error.response?.data, null, 2));
            console.error("HMRC Error Headers:", JSON.stringify(error.response?.headers, null, 2));
            throw error;
        }

    });

});