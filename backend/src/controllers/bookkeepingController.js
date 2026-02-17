const bookeepingService = require("../services/bookkeepingServices");

class bookkeepingController {
    
    async addRecipt(req, res) {
        try {
            const reciptData = req.body;
            const userId = req.user.userId;
            await bookeepingService.addRecipt(userId, reciptData);
            res.status(200).json({ message: 'Recipt added successfully' });
        } catch (error) {
            console.error('Error adding recipt:', error);
            res.status(500).json({ error: 'Failed to add recipt' });
        }
    }
}   
module.exports = new bookkeepingController();