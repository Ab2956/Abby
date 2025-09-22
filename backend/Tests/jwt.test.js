require('dotenv').config();
const jwt = require('jsonwebtoken');
const {jwtVerification} = require('../src/middleware/jwtAuth');
const jwtServices = require('../src/services/jwtServices');


jest.mock('axios');

describe("Test jwt", () => {
    it("can create token", () => {
        const userId = '1';
        const token = jwtServices.createJWT(userId);

        expect(typeof token).toBe('string');

        const decoded = jwt.decode(token);

        expect(decoded.userID).toBe(userId);
        expect(decoded.exp).toBeDefined();
        expect(decoded.iat).toBeDefined();

    });
    it("can verify token", () => {
        const userId = '1';
        const token = jwtServices.createJWT(userId);

        const verifiedJWT = jwtServices.verifyJWT(token);

        expect(verifiedJWT).not.toBeNull();
        expect(verifiedJWT.userID).toBe(userId);
    });
});


