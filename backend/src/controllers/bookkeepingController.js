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
    async getRecipts(req, res) {
        try {
            const userId = req.user.userId;
            const recipts = await bookeepingService.getRecipts(userId);
            res.status(200).json(recipts);
        } catch (error) {
            console.error('Error fetching recipts:', error);
            res.status(500).json({ error: 'Failed to fetch recipts' });
        }
    }
    async deleteRecipt(req, res) {
        try {
            const reciptId = req.params.id;
            await bookeepingService.deleteRecipt(reciptId);
            res.status(200).json({ message: 'Recipt deleted successfully' });
        } catch (error) {
            console.error('Error deleting recipt:', error);
            res.status(500).json({ error: 'Failed to delete recipt' });
        }
    }
    async handleUpload(file) {
        try {
            if (!file || !file.buffer) {
                throw new Error('No file provided');
            }
            if (file.mimetype == "application/pdf") {
                const parsedFile = await pdfParser.parseFile(file.buffer);
                await bookeepingService.addRecipt(parsedFile);
            }
        } catch (error) {
            console.error('Error handling file upload:', error);
            throw error;
        }
    }
    async getReciptById(req, res) {
        try {
            const reciptId = req.params.id;
            const recipt = await bookeepingService.getReciptById(reciptId);
            if (!recipt) {
                return res.status(404).json({ error: 'Recipt not found' });
            }
            res.status(200).json(recipt);
        } catch (error) {
            console.error('Error fetching recipt:', error);
            res.status(500).json({ error: 'Failed to fetch recipt' });
        }
    }
    async getAllUserRecipts(req, res) {
        try {
            const userId = req.user.userId;
            const recipts = await bookeepingService.getRecipts(userId);
            res.status(200).json(recipts);
        } catch (error) {
            console.error('Error fetching user recipts:', error);
            res.status(500).json({ error: 'Failed to fetch user recipts' });
        }
    }

}
module.exports = new bookkeepingController();