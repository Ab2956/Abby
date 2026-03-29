const HttpClient = require('../utils/httpClient')
const db = require('../database/dataHandler');
const HMRC_BASE_URL = 'https://test-api.service.hmrc.gov.uk'
const mtdServices = require('./mtdServices');

class HmrcService {
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
        return this.httpClient.post(`/organisations/vat/${vrn}/returns`,
            payload, this.fraudHeaders);

    }
    async getBusinessId(nino) {
        return this.httpClient.get(`/individuals/business/details/${nino}/list`, null, this.fraudHeaders);
    }

    async submitQuarterlyData(nino, businessId, quarter, taxYear, data) {

        try {
            const periodDates = mtdServices.getPeriodDates(quarter, taxYear);
            const formattedData = mtdServices.formatForHmrc(data);
            const extraHeaders = {
                ...this.fraudHeaders,
            };

            return this.httpClient.post(`/individuals/business/self-employment/${nino}/${businessId}/period`, {
                ...periodDates,
                ...formattedData
            }, extraHeaders);

        } catch (error) {
            const errorMsg = error.response?.data ? JSON.stringify(error.response.data) : error.message;
            console.error('Error submitting data to HMRC:', errorMsg);
            throw new Error('Failed to submit data to HMRC');
        }
    }
    
}
module.exports = HmrcService;