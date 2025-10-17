const jwt = require("jsonwebtoken");
const authServices = require('../services/authServices');
const clientServices = require('../services/clientServices');
const {createJWT} = require('../services/jwtServices');

exports.login = (req, res) => {
    const url = authServices.createUrl();
    console.log(url);
    res.redirect(authServices.createUrl());

};

exports.callback = async (req, res) => {
    const {code} = req.query;
    const tokenData = await authServices.getTokenData(code);
    //const accessToken = tokenData.access_token;

    // const user = await clientServices.getUser(accessToken);
    
    // console.log(user);

    console.log(tokenData);

    // const user = await authServices.getUser(accessToken);

    //const jwtToken = createJWT(user.userId);
    res.json({tokenData});
    
};



