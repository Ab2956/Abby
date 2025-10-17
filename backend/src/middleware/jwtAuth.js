const jwtService = require('../services/jwtServices');

function jwtVerification(req, res, next){

    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if(!token){
        return res.status(401).json({error: "No token"})
    }
    const user = jwtService.verifyJWT(token);

    if(!user){
        return res.status(403).json({error: "Invalid token"})
    }
        req.user = user;
        next();
}
module.exports = jwtVerification;

