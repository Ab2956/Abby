const axios = require('axios');

class oauthClient{
    constructor(baseUrl){
        this.client = axios.create({
            baseURL: baseUrl
        });
    }
    async get(path, headers = {}){
        const response = await this.client.get(path,{headers});
        return response.data;
    };
    async post(path, data = {}, headers ={}){
        const response = await this.client.post(path,data,{headers});
        return response.data;
    };
}
module.exports = oauthClient;