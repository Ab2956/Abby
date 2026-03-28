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
}
module.exports = new MtdController();