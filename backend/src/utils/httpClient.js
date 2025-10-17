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
    async get(path, params){
        const response = await this.client.get(path,{params});
        return response.data;
    };
    async post(path, body){
        const response = await this.client.post(path,body);
        return response.data;
    };
}
module.exports = HttpClient;