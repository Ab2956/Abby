const bookkeepingDataHandler = require('../database/bookkeepingDataHandler');
const invoiceDataHandler = require('../database/invoiceDataHandler');

class vatService {

    async calculateTotalVat(userId) {
        try {

            // gets all vat data for user and sums it up
            const totalVatFromRecipts = await bookkeepingDataHandler.getAllVatAmountsByUserId(userId);
            const totalVatFromInvoices = await invoiceDataHandler.getAllVatAmountsByUserId(userId);

            const totalVat = totalVatFromRecipts + totalVatFromInvoices;

            return totalVat;
        } catch (error) {
            console.error("Error calculating total VAT:", error);
            throw error;
        }
    }
}
module.exports = new vatService();