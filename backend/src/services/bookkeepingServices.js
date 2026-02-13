class BookkeepingService {

    async addRecpit(recipt) {
       return await dataHandler.addRecpit(recipt);
        
    }
}

module.exports = BookkeepingService;