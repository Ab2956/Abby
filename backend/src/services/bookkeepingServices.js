const dataHandler = require('../database/dataHandler');

class BookkeepingService {

    async addRecipt(userId, recipt) {

        return await dataHandler.addRecpit(userId, recipt);

    }
    async getRecipts(userId) {
        return await dataHandler.getReciptsByUserId(userId);
    }
    async deleteRecipt(reciptId) {
        return await dataHandler.deleteRecipt(reciptId);
    }
}

module.exports = BookkeepingService;