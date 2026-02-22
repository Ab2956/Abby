const jwtService = require('../services/jwtServices');

function jwtVerification(req, res, next){

    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if(!token){
        return res.status(401).json({error: "No token"})
    }

    const decoded = jwtService.verifyJWT(token);

    if(!decoded){
        return res.status(403).json({error: "Invalid token"})
    }
    req.user = decoded.payload;
    next();
}
module.exports = {jwtVerification};

