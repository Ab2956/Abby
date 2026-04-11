const bookkeepingDataHandler = require('../database/bookkeepingDataHandler');

class BookkeepingService {
    // Service functions for bookkeeping operations, interacting with the bookkeepingDataHandler for database operations

    async addRecipt(userId, recipt) {
        return await bookkeepingDataHandler.addRecpit(userId, recipt);
    }
    
    async getRecipts(userId) {
        return await bookkeepingDataHandler.getReciptsByUserId(userId);
    }

    async deleteRecipt(reciptId) {
        return await bookkeepingDataHandler.deleteRecipt(reciptId);
    }
}

module.exports = new BookkeepingService();