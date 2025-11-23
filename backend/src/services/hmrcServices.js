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
        return this.httpClient.get(`/obligations/vat/${vrn}/obligations`, {
            from,
            to,
            status
        });

    }
    async submitObligations(vrn, payload) {
        return this.httpClient.post(`/obligations/vat/${vrn}/obligations`,
            payload);

    }

}
module.exports = HmrcService;