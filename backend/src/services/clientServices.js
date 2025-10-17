const HttpClient = require('../utils/httpClient');

module.exports = {
getUser: async (accessToken) => {
    
        const httpClient = new HttpClient("https://test-api.service.hmrc.gov.uk",accessToken)

        const data = await httpClient.get('/individuals/details');
        const userData = data.selfAssessment

        return {
            name: `${userData.name.firstName} ${userData.name.lastName}`,
            nino: userData.ids.nino
        };
}
};