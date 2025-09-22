require('dotenv').config();
const jwt = require('jsonwebtoken');
const SECRET = process.env.JWT_SECRET;

function createJWT(userID){
    return jwt.sign({userID}, SECRET, {expiresIn: "1h"});
}

function verifyJWT(token){
    try {
        return jwt.verify(token, SECRET);
    } catch (error) {
        return null;
    }
}
module.exports= {createJWT,verifyJWT};