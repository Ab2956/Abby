require('dotenv').config();
const jwt = require('jsonwebtoken');
const { jwtVerification } = require('../src/middleware/jwtAuth');
const jwtServices = require('../src/services/jwtServices');


jest.mock('axios');

describe("Test JWT", () => {
    it("can create token", () => {
        const userId = '1';
        const email = 'test@example.com';
        const token = jwtServices.createJWT({id: userId, email: email});

        expect(typeof token).toBe('string');

        const decoded = jwt.decode(token);

        expect(decoded.payload.id).toBe(userId);
        expect(decoded.exp).toBeDefined();
        expect(decoded.iat).toBeDefined();

    });

    it("can verify token", () => {
        const userId = '1';
        const email = 'test@example.com';
        const token = jwtServices.createJWT({id: userId, email: email});
        console.log(token);

        const verifiedJWT = jwtServices.verifyJWT(token);
        console.log(verifiedJWT);

        expect(verifiedJWT).not.toBeNull();
        expect(verifiedJWT.payload.id).toBe(userId);
    });
});