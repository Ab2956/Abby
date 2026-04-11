const vatService = require('../services/vatService');

class VatController {
    // Controller to handle VAT related operations to get total vat
    
    async getTotalVat(req, res) {
        try {
            const userId = req.user.userId;
            const totalVat = await vatService.calculateTotalVat(userId);

            res.json({ totalVat });
        } catch (error) {
            res.status(500).json({ error: 'Failed to calculate total VAT' });
        }   
    }
}
module.exports = new VatController();
