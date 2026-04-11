const HmrcService = require("../services/hmrcServices");
const userServices = require("../services/userServices");
const mtdServices = require("../services/mtdServices");
const fraudPreventionBuilder = require("../services/fraudPreventionBuilder");


// Controller to handle Making Tax Digital related operations

class MtdController {

    constructor() {
        this.uploadQuarterData = this.uploadQuarterData.bind(this);
        this.submitToHmrc = this.submitToHmrc.bind(this);
    }

    // helper function to get the correct intance
    async getHmrcService(userId, req, forceRefresh = false) {
        const accessToken = await userServices.getValidAccessToken(userId, forceRefresh);
        const deviceInfo = fraudPreventionBuilder.extractDeviceInfo(req);
        const fraudHeaders = await fraudPreventionBuilder.buildHeaders(deviceInfo, userId, req);
        return new HmrcService(accessToken, fraudHeaders);
    }

    async uploadQuarterData(req, res) {
        try {
            const userId = req.user.userId; 
            const { quarter, taxYear, data } = req.body;

            const result = await mtdServices.uploadQuarterData(userId, quarter, taxYear, data);

            res.status(200).json({ message: 'Quarter data uploaded successfully', result });
        } catch (error) {
            console.error('Error uploading quarter data:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    }

    // Submit data to HMRC using the constuctor to get token and headers
    async submitToHmrc(req, res) {
        try {
            const userId = req.user.userId;
            const vrn = await userServices.getVrn(userId);
            if (!vrn) {
                return res.status(400).json({ message: 'No VRN found for user, please update your profile' });
            }
            const { quarter, taxYear, data } = req.body;

            let hmrcService = await this.getHmrcService(userId, req);

            try {
                const result = await hmrcService.submitVATQuarterlyData(vrn, quarter, taxYear, data);
                return res.status(200).json({ message: 'Data submitted to HMRC successfully', result });

            } catch (error) {
                if (error.message && error.message.includes('INVALID_CREDENTIALS')) {
                    hmrcService = await this.getHmrcService(userId, req, true);
                    const result = await hmrcService.submitVATQuarterlyData(vrn, quarter, taxYear, data);
                    return res.status(200).json({ message: 'Data submitted to HMRC successfully', result });
                }
                throw error;
            }

        } catch (error) {
            console.error('Error submitting data to HMRC:', error);
            res.status(500).json({ error: 'Failed to submit data to HMRC' });
        }
    }
}
module.exports = new MtdController();