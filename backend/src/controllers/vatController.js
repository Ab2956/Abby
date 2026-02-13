class VatController {
    async getTotalVat(req, res) {
        try {
            // Logic to calculate total VAT from invoices and receipts
            const totalVat = 0; // Placeholder for calculated VAT
            res.json({ totalVat });
        } catch (error) {
            res.status(500).json({ error: 'Failed to calculate total VAT' });
        }   
    }
}
module.exports = new VatController();
