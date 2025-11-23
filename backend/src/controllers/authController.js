const jwt = require("jsonwebtoken");
const authServices = require('../services/authServices');
const userServices = require('../services/userServices.js');
const User = require('../models/UserSchema.js');


exports.loginToOAuth = async(req, res) => {
    const url = authServices.createUrl();
    console.log(url);

    res.redirect(authServices.createUrl());

};

exports.callback = async(req, res) => {
    const { code } = req.query;
    const tokenData = await authServices.getTokenData(code);
    const { access_token, refresh_token, expires_in } = tokenData;
    console.log(access_token);

    //const userData = await userServices.getUser(access_token);

    // let user = await User.findOneAndUpdate({
    //     userId: userData.userId
    // },{
    //     accessToken: access_token, 
    //     refreshToken: refresh_token, 
    //     tokenExpiry: new Date(Date.now()) + expires_in * 1000,
    // },{
    //     upsert: true, new:true});

    console.log(tokenData);
    //console.log(user);
    // const redirectUrl = `abby://auth=success?id=${user.id}`;
    // res.redirect(redirectUrl);

    // const user = await authServices.getUser(accessToken);

    //const jwtToken = createJWT(user.userId);
    res.json({ tokenData });

};