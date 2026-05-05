const HttpClient = require('../utils/httpClient')
const db = require('../database/dataHandler');
const HMRC_BASE_URL = 'https://test-api.service.hmrc.gov.uk'
const mtdServices = require('./mtdServices');

class HmrcService {

    // Service functions for interacting with the HMRC API

    // constructor to initialize the HttpClient with the base URL and access token, headers for fraud prevention
    constructor(accessToken, fraudHeaders = {}) {
        this.httpClient = new HttpClient(
            HMRC_BASE_URL,
            accessToken
        );
        this.fraudHeaders = fraudHeaders;
    }

    async getObligations(vrn, from, to, status) {
        try {
            return await this.httpClient.get(`/organisations/vat/${vrn}/obligations`, {
                from,
                to,
                status
            }, this.fraudHeaders);
        } catch (error) {
            const errorMsg = error.response?.data ? JSON.stringify(error.response.data) : error.message;
            throw new Error(`Failed to get obligations: ${errorMsg}`);
        }
    }

    async submitObligations(vrn, payload) {
        try {
            return await this.httpClient.post(`/organisations/vat/${vrn}/returns`,
                payload, this.fraudHeaders);
        } catch (error) {
            const errorMsg = error.response?.data ? JSON.stringify(error.response.data) : error.message;
            throw new Error(`Failed to submit VAT return: ${errorMsg}`);
        }
    }
    async getBusinessId(nino) {
        return this.httpClient.get(`/individuals/business/details/${nino}/list`, null, this.fraudHeaders);
    }

    // Function to submit VAT quarterly data to HMRC
    async submitVATQuarterlyData(vrn, quarter, taxYear, data) {

        try {
            const periodDates = mtdServices.getPeriodDates(quarter, taxYear);
            const formattedData = mtdServices.formatVATForHmrc(data);
            const extraHeaders = {
                ...this.fraudHeaders,
            };

            return this.httpClient.post(`/organisations/vat/${vrn}/returns`,
                formattedData, extraHeaders);

        } catch (error) {
            const errorMsg = error.response?.data ? JSON.stringify(error.response.data) : error.message;
            console.error('Error submitting data to HMRC:', errorMsg);
            throw error;
        }
    }
    
}
module.exports = HmrcService;