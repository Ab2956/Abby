const crypto = require('crypto');
const ENCRYPTION_KEY = process.env.TOKEN_ENCRYPTION_KEY || crypto.randomBytes(32).toString('hex');

// encryption for the tokens using crypto
function encryptToken(token) {
    if (!token) return null;
    
    const key = Buffer.from(ENCRYPTION_KEY, 'hex').slice(0, 32);
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv('aes-256-cbc', key, iv);
    
    let encrypted = cipher.update(token, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    
    return iv.toString('hex') + ':' + encrypted;
}

function decryptToken(encryptedToken) {
    if (!encryptedToken) return null;
    
    const parts = encryptedToken.split(':');
    if (parts.length !== 2) return null;
    
    const key = Buffer.from(ENCRYPTION_KEY, 'hex').slice(0, 32);
    const iv = Buffer.from(parts[0], 'hex');
    const encryptedData = parts[1];
    
    const decipher = crypto.createDecipheriv('aes-256-cbc', key, iv);
    
    let decrypted = decipher.update(encryptedData, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    
    return decrypted;
}

module.exports = { encryptToken, decryptToken };
