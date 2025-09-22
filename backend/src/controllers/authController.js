const jwt = require("jsonwebtoken");
const authServices = require('../services/authServices');
const {createJWT} = require('../services/jwtServices');

exports.login = (req, res) => {
    res.redirect(authServices.createUrl());
};

exports.callback = async (req, res) => {
    const {code} = req.query;
    const tokenData = await authServices.exchangeForToken(code);
    const accessToken = tokenData.access_token;
    const user = await authServices.getUser(accessToken);

    await authServices.exchangeForToken(code);

    const jwtToken = createJWT(user.userId);
    res.json({token: jwtToken, user});
};



