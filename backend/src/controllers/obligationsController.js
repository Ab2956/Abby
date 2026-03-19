const HmrcService = require('../services/hmrcServices');
const userServices = require('../services/userServices');
const fraudPreventionBuilder = require('../services/fraudPreventionBuilder');

class obligationsController {

    constructor() {
        this.getObligations = this.getObligations.bind(this);
        this.submitObligation = this.submitObligation.bind(this);
    }

    async getHmrcService(userId, req, forceRefresh = false) {
        const accessToken = await userServices.getValidAccessToken(userId, forceRefresh);
        const deviceInfo = fraudPreventionBuilder.extractDeviceInfo(req);
        const fraudHeaders = await fraudPreventionBuilder.buildHeaders(deviceInfo, userId, req);
        return new HmrcService(accessToken, fraudHeaders);
    }

    async getObligations(req, res) {
        try {
            const userId = req.user.userId;

            const vrn = await userServices.getVrn(userId);
            if (!vrn) {
                return res.status(400).json({ error: 'No VRN found for user, please update your profile' });
            }

            const { from, to, status } = req.query;

            let hmrcService = await this.getHmrcService(userId, req);
            try {
                const obligationsData = await hmrcService.getObligations(vrn, from, to, status);
                return res.json(obligationsData);
            } catch (error) {
                // If HMRC rejected the token, force-refresh and retry once
                if (error.message && error.message.includes('INVALID_CREDENTIALS')) {
                    hmrcService = await this.getHmrcService(userId, req, true);
                    const obligationsData = await hmrcService.getObligations(vrn, from, to, status);
                    return res.json(obligationsData);
                }
                throw error;
            }

        } catch (error) {
            console.error('Error fetching obligations:', error);
            const message = error.message && error.message.includes('refresh token')
                ? 'HMRC session expired, please reconnect to HMRC'
                : 'Failed to fetch obligations';
            res.status(500).json({ error: message });
        }
    }

    async submitObligation(req, res) {
        try {
            const userId = req.user.userId;

            const vrn = await userServices.getVrn(userId);
            if (!vrn) {
                return res.status(400).json({ error: 'No VRN found for user, please update your profile' });
            }

            const obligationData = req.body;

            let hmrcService = await this.getHmrcService(userId, req);
            try {
                const result = await hmrcService.submitObligations(vrn, obligationData);
                return res.json(result);
            } catch (error) {
                if (error.message && error.message.includes('INVALID_CREDENTIALS')) {
                    hmrcService = await this.getHmrcService(userId, req, true);
                    const result = await hmrcService.submitObligations(vrn, obligationData);
                    return res.json(result);
                }
                throw error;
            }

        } catch (error) {
            console.error('Error submitting obligation:', error);
            const message = error.message && error.message.includes('refresh token')
                ? 'HMRC session expired, please reconnect to HMRC'
                : 'Failed to submit obligation';
            res.status(500).json({ error: message });
        }
    }
}

module.exports = new obligationsController();