const HmrcService = require("../services/hmrcServices");
const userServices = require("../services/userServices");
const hmrcService = new HmrcService();

class MtdController {

    async uploadQuarterData(req, res) {
        try {
            const { userId } = req.userId; 
            const { quarter, taxYear, data } = req.body;

            // Call the service method to handle the upload
            const result = await mtdService.uploadQuarterData(userId, quarter, taxYear, data);

            res.status(200).json({ message: 'Quarter data uploaded successfully', result });
        } catch (error) {
            console.error('Error uploading quarter data:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    }
    async submitToHmrc(req, res) {
        try {
            const { userId } = req.userId; 
            const nino = await userServices.getNino(userId);
            if (!nino) {
                return res.status(400).json({ message: 'No NINO found for user, please update your profile' });
            }
            const businessId = await userServices.getBusinessId(nino);
            if (!businessId) {
                return res.status(400).json({ message: 'No business ID found for user' });
            }
            const { quarter, taxYear, data } = req.body;

            const result = await hmrcService.submitQuarterlyData(nino, businessId, quarter, taxYear, data);
            res.status(200).json({ message: 'Data submitted to HMRC successfully', result });
        } catch (error) {
            console.error('Error submitting data to HMRC:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    }
}
module.exports = new MtdController();