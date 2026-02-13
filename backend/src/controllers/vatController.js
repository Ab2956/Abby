const vatService = require('../services/vatService');

class VatController {
    async getTotalVat(req, res) {
        try {
            const totalVat = await vatService.calculateTotalVat();
            res.json({ totalVat });
        } catch (error) {
            res.status(500).json({ error: 'Failed to calculate total VAT' });
        }   
    }
}
module.exports = new VatController();
