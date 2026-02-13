require('dotenv').config();
const { encryptToken, decryptToken } = require('../src/utils/tokenEncryption');

describe('Token Encryption/Decryption', () => {
    it('can encrypt and decrypt a refresh token', () => {
        const originalToken = '489195957c2438879b8b2698f1514ab1';
        
        // Encrypt
        const encrypted = encryptToken(originalToken);
        console.log('Encrypted token:', encrypted);
        expect(encrypted).not.toBe(originalToken);
        expect(encrypted).toContain(':');
        
        // Decrypt
        const decrypted = decryptToken(encrypted);
        console.log('Decrypted token:', decrypted);
        expect(decrypted).toBe(originalToken);
    });

    it('handles null values', () => {
        expect(encryptToken(null)).toBeNull();
        expect(decryptToken(null)).toBeNull();
    });

    it('returns null for invalid encrypted format', () => {
        expect(decryptToken('invalid-no-colon')).toBeNull();
    });
});
