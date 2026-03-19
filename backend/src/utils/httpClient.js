const axios = require('axios');
// helper class for a get and post methods.
class HttpClient{
    constructor(baseUrl, accessToken){
    this.client = axios.create({
        baseURL: baseUrl,
        headers: {
            Authorization: `Bearer ${accessToken}`,
            Accept: "application/vnd.hmrc.1.0+json",
            }
        });
    }
    async get(path, params, extraHeaders = {}){
        const response = await this.client.get(path, { params, headers: extraHeaders });
        return response.data;
    };
    async post(path, body, extraHeaders = {}){
        const response = await this.client.post(path, body, { headers: extraHeaders });
        return response.data;
    };
}
module.exports = HttpClient;