const datahandler = require('../database/dataHandler');

class vatService {

    async calculateTotalVat() {
        try {

            const userInvoices = await datahandler.getInvoices(userId);
            // get all the total vat and sum them up

            const totalVat = await datahandler.getVatTotalbyUserId(userId);
            return totalVat;
        } catch (error) {
            console.error("Error calculating total VAT:", error);
            throw error;
        }
    }
}
module.exports = new vatService();