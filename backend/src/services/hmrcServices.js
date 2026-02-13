const HttpClient = require('../utils/httpClient')
const db = require('../database/dataHandler');
const HMRC_BASE_URL = 'https://test-api.service.hmrc.gov.uk'

class HmrcService {
    constructor(accessToken) {
        this.httpClient = new HttpClient(
            HMRC_BASE_URL,
            accessToken
        );
    }
    async getObligations(vrn, from, to, status) {
        try {
            return await this.httpClient.get(`/organisations/vat/${vrn}/obligations`, {
                from,
                to,
                status
            });
        } catch (error) {
            const errorMsg = error.response?.data ? JSON.stringify(error.response.data) : error.message;
            throw new Error(`Failed to get obligations: ${errorMsg}`);
        }
    }
    async submitObligations(vrn, payload) {
        return this.httpClient.post(`/organisations/vat/${vrn}/returns`,
            payload);

    }
    

}
module.exports = HmrcService;