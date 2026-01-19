const authServices = require('../services/authServices');
const userServices = require('../services/userServices.js');
const User = require('../models/UserSchema.js');
const redisCache = require("../utils/redisCache.js");
const crypto = require('crypto');

exports.loginToOAuth = async(req, res) => {

    const userEmail = req.user.email;
    const user =  await userServices.getUserByEmail(userEmail);

    if(user.hrmc_connected == false){
        const state = crypto.randomBytes(32).toString('hex');

       await redisCache.set(state, user._id.toString(), 10 * 60);

        const url = authServices.createUrl(state);
        console.log(url);
        res.redirect(url);
    }else{
        res.json({message: "User already connected to HMRC"});
    }
};
exports.testOAuth = async(req, res) => {
    const testEmail = "romwan.newton@example.com"; // Hardcoded for testing
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

    const updateData = {
        hrmc_connected: true,
        refresh_token: refresh_token,
        token_expiration: Date.now() + (expires_in * 1000)
    };
    await userServices.updateUser(userId, updateData);

    res.json({ tokenData });
    } catch (error) {
        console.error("OAuth callback error:", error);
        res.status(500).json({ error: "Internal server error" });
    }

};