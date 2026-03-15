const authServices = require('../services/authServices');
const userServices = require('../services/userServices.js');
const redisCache = require("../utils/redisCache.js");
const crypto = require('crypto');
const { encryptToken } = require('../utils/tokenEncryption');

exports.loginToOAuth = async(req, res) => {

    const userId = req.user.userId;
    const isConnectedToHmrc = await userServices.isConnectedToHMRC(userId);

    if (!isConnectedToHmrc) {
        const state = crypto.randomBytes(32).toString('hex');

        await redisCache.set(state, userId.toString(), 10 * 60);

        const url = authServices.createUrl(state);
        console.log(url);
        res.redirect(url);
    } else {
        res.json({ message: "User already connected to HMRC" });
    }
};
exports.testOAuth = async(req, res) => {
    const testEmail = "romwan.newton@example.com"; // Hardcoded for testing
    const password = "testpassword"; // Hardcoded for testing
    const user = await userServices.getUserByEmail(testEmail);

    if (!user) {
        return res.status(404).json({ error: "Test user not found. Create account first." });
    }

    const state = crypto.randomBytes(32).toString('hex');
    await redisCache.set(state, user._id.toString(), 10 * 60);

    const url = authServices.createUrl(state);
    console.log(url);
    res.redirect(url);
};

exports.callback = async(req, res) => {
    try {
        const { code, state } = req.query;

        const userId = await redisCache.get(state);
        if (!userId) {
            return res.status(400).json({ error: "Invalid or expired state parameter" });
        }
        await redisCache.delete(state);

        const tokenData = await authServices.getTokenData(code);
        const { access_token, refresh_token, expires_in } = tokenData;
        const encrypted_refresh = encryptToken(refresh_token);
        const encrypted_access = encryptToken(access_token);
        console.log("Token Data:", tokenData, );

        const updateData = {
            hmrc_connected: true,
            access_token: encrypted_access,
            refresh_token: encrypted_refresh,
            token_expiration: Date.now() + (expires_in * 1000)
        };
        await userServices.updateUser(userId, updateData);

        // Redirect back into the app
        res.redirect('abby://oauth-callback?success=true');
    } catch (error) {
        console.error("OAuth callback error:", error);
        res.redirect('abby://oauth-callback?success=false&error=' + encodeURIComponent(error.message));
    }

};