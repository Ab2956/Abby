const datahandler = require('../database/dataHandler');

class vatService {

    async calculateTotalVat() {
        try {
            
            // Implement logic to calculate total VAT from the database
            const totalVat = await datahandler.getVatTotalbyUserId(userId);
            return totalVat;
        } catch (error) {
            console.error("Error calculating total VAT:", error);
            throw error;
        }   
    }
}
module.exports = new vatService();