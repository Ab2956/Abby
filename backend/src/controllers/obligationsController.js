const obligations = require('../services/hmrcServices');

class obligationsController {

    async getObligations(req, res) {
        try {
            const { vrn } = req.params;
            const obligationsData = await obligations.getObligations(vrn);
            res.json(obligationsData);
        } catch (error) {
            console.error('Error fetching obligations:', error);
            res.status(500).json({ error: 'Failed to fetch obligations' });
        }
    }

}