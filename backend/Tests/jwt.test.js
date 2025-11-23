require('dotenv').config();
const jwt = require('jsonwebtoken');
const { jwtVerification } = require('../src/middleware/jwtAuth');
const jwtServices = require('../src/services/jwtServices');


jest.mock('axios');

describe("Test JWT", () => {
    it("can create token", () => {
        const userId = '1';
        const token = jwtServices.createJWT(userId);

        expect(typeof token).toBe('string');

        const decoded = jwt.decode(token);

        expect(decoded.userId).toBe(userId);
        expect(decoded.exp).toBeDefined();
        expect(decoded.iat).toBeDefined();

    });

    it("can verify token", () => {
        const userId = '1';
        const token = jwtServices.createJWT(userId);
        console.log(token);

        const verifiedJWT = jwtServices.verifyJWT(token);
        console.log(verifiedJWT);

        expect(verifiedJWT).not.toBeNull();
        expect(verifiedJWT.userId).toBe(userId);
    });
});