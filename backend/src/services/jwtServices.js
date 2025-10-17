require('dotenv').config();
const jwt = require('jsonwebtoken');
const SECRET = process.env.JWT_SECRET;

class jwtServices{
    constructor(){}

   static createJWT(userID){
    return jwt.sign({userID}, SECRET, {expiresIn: "1h"});
}

static verifyJWT(token){
    try {
        return jwt.verify(token, SECRET);
    } catch (error) {
        return null;
    }
}
}

module.exports= jwtServices;