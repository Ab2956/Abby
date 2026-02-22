const authServices = require('../services/authServices');
const HmrcService = require('../services/hmrcServices');
const obligations = require('../services/hmrcServices');
const userServices = require('../services/userServices');

class obligationsController {

    async getObligations(req, res) {
        try {

            const refreshToken = await authServices.getUserRefreshToken(req.user.userId);
            if (!refreshToken) {
                return res.status(401).json({ error: 'No refresh token found, please connect to HMRC' });
            }

            const tokenData = await userServices.getRefreshToken(refreshToken);
            const accessToken = tokenData.access_token;

            const hmrcService = new HmrcService(accessToken);
        
            const { vrn, from, to, status } = req.query;
            const obligationsData = await hmrcService.getObligations(vrn, from, to, status);
            res.json(obligationsData);

        } catch (error) {
            console.error('Error fetching obligations:', error);
            res.status(500).json({ error: 'Failed to fetch obligations' });
        }
    }
    async submitObligation(req, res) {
        try {
            const { vrn } = req.params;
            const obligationData = req.body;
            const result = await hmrcService.submitObligation(vrn, obligationData);
            res.json(result);
        } catch (error) {
            console.error('Error submitting obligation:', error);
            res.status(500).json({ error: 'Failed to submit obligation' });
        }
    }
}

module.exports = new obligationsController();