const userServices = require('../services/userServices');

class UserController {
    async getUserInfo(req, res) {
        try {
            const userId = req.user.userId;
            const userInfo = await userServices.getUserInfo(userId);
            res.json(userInfo);
        } catch (error) {
            console.error('Error fetching user info:', error);
            res.status(500).json({ error: 'Failed to fetch user info' });
        }   
    }
    async updateUserInfo(req, res) {
        try {   
            const userId = req.user.userId;
            const updateData = req.body;
            const updatedUserInfo = await userServices.updateUserInfo(userId, updateData);
            res.json(updatedUserInfo);
        } catch (error) {
            console.error('Error updating user info:', error);
            res.status(500).json({ error: 'Failed to update user info' });
        }
    }
    async updateVrn(req, res) {
        try {
            const userId = req.user.userId;
            const { vrn } = req.body;
            const updatedUserInfo = await userServices.updateVrn(userId, vrn);
            res.json(updatedUserInfo);
        } catch (error) {
            console.error('Error updating VRN:', error);
            res.status(500).json({ error: 'Failed to update VRN' });
        }   
    }
    async updatePassword(req, res) {
        try {
            const userId = req.user.userId;
            const { currentPassword, newPassword } = req.body;
            await userServices.updatePassword(userId, currentPassword, newPassword);
            res.json({ message: 'Password updated successfully' });
        } catch (error) {
            console.error('Error updating password:', error);
            res.status(500).json({ error: 'Failed to update password' });
        }
    }
    async addUserName(req, res) {
        try {
            const userId = req.user.userId;
            const { name } = req.body;
            const updatedUserInfo = await userServices.addUserName(userId, name);
            res.json(updatedUserInfo);
        } catch (error) {
            console.error('Error adding user name:', error);
            res.status(500).json({ error: 'Failed to add user name' });
        }
    }
}

module.exports = new UserController();