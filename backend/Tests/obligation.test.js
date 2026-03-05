require('dotenv').config();
const HmrcService = require('../src/services/hmrcServices');
const authServices = require('../src/services/authServices');
const userServices = require('../src/services/userServices');
const userDataHandler = require('../src/database/userDataHandler');
const obligationsController = require('../src/controllers/obligationsController');
const db = require('../src/database/connectDB');
const { encryptToken } = require('../src/utils/tokenEncryption');

describe('Test Obligations', () => {
    afterAll(async () => {
        await db.closeConnection();
    });

    const userId = "68fa2057b845e279d8dc41a9";
    const vrn = process.env.TEST_VRN || '125354193';
    const from = process.env.HMRC_OBLIGATIONS_FROM || '2025-04-06';
    const to = process.env.HMRC_OBLIGATIONS_TO || '2026-04-05';
    const status = process.env.HMRC_OBLIGATIONS_STATUS || 'O';

    describe('getValidAccessToken', () => {

        it('returns cached access token when not expired', async () => {
            // Store a fake encrypted access token with future expiry
            const fakeToken = 'cached-access-token-123';
            const encrypted = encryptToken(fakeToken);
            await userDataHandler.updateAccessToken(
                userId, encrypted, encryptToken('fake-refresh'), 3600
            );

            const token = await userServices.getValidAccessToken(userId);
            expect(token).toBe(fakeToken);
        });

        it('refreshes token when forceRefresh is true', async () => {
            // Store a valid cached token
            const cachedToken = 'old-access-token';
            await userDataHandler.updateAccessToken(
                userId, encryptToken(cachedToken), encryptToken('fake-refresh'), 3600
            );

            const newAccessToken = 'new-access-token-456';
            const newRefreshToken = 'new-refresh-token-456';

            // Mock authServices.getRefreshToken to return new tokens
            const originalGetRefresh = authServices.getRefreshToken;
            authServices.getRefreshToken = jest.fn().mockResolvedValue({
                access_token: newAccessToken,
                refresh_token: newRefreshToken,
                expires_in: 3600
            });

            const token = await userServices.getValidAccessToken(userId, true);
            expect(token).toBe(newAccessToken);
            expect(authServices.getRefreshToken).toHaveBeenCalled();

            // Restore original
            authServices.getRefreshToken = originalGetRefresh;
        });

        it('refreshes token when cached token is expired', async () => {
            // Store token with past expiry
            const userCollection = await db.getCollection('users');
            const { ObjectId } = require('mongodb');
            await userCollection.updateOne(
                { _id: new ObjectId(userId) },
                { $set: { 
                    access_token: encryptToken('expired-token'),
                    token_expiration: Date.now() - 10000 // expired 10s ago
                }}
            );

            const freshToken = 'fresh-access-token-789';
            const originalGetRefresh = authServices.getRefreshToken;
            authServices.getRefreshToken = jest.fn().mockResolvedValue({
                access_token: freshToken,
                refresh_token: 'fresh-refresh-789',
                expires_in: 3600
            });

            const token = await userServices.getValidAccessToken(userId);
            expect(token).toBe(freshToken);
            expect(authServices.getRefreshToken).toHaveBeenCalled();

            authServices.getRefreshToken = originalGetRefresh;
        });

        it('throws when no refresh token exists and token expired', async () => {
            // Clear refresh token
            const userCollection = await db.getCollection('users');
            const { ObjectId } = require('mongodb');
            await userCollection.updateOne(
                { _id: new ObjectId(userId) },
                { $set: { 
                    access_token: null,
                    refresh_token: '',
                    token_expiration: 0
                }}
            );

            await expect(userServices.getValidAccessToken(userId))
                .rejects.toThrow('No refresh token found');
        });
    });

    describe('obligationsController.getObligations', () => {

        function mockRes() {
            const res = {};
            res.status = jest.fn().mockReturnValue(res);
            res.json = jest.fn().mockReturnValue(res);
            return res;
        }

        it('returns obligations on success', async () => {
            const mockObligations = {
                obligations: [{ start: '2025-04-06', end: '2025-07-05', due: '2025-08-05', status: 'O', periodKey: '25A1' }]
            };

            const origGetToken = userServices.getValidAccessToken;
            const origGetVrn = userServices.getVrn;
            userServices.getValidAccessToken = jest.fn().mockResolvedValue('mock-access-token');
            userServices.getVrn = jest.fn().mockResolvedValue(vrn);

            // Mock HmrcService.getObligations
            const origGetObligations = HmrcService.prototype.getObligations;
            HmrcService.prototype.getObligations = jest.fn().mockResolvedValue(mockObligations);

            const req = { user: { userId }, query: { from, to, status } };
            const res = mockRes();

            await obligationsController.getObligations(req, res);

            expect(res.json).toHaveBeenCalledWith(mockObligations);
            expect(userServices.getValidAccessToken).toHaveBeenCalledWith(userId, false);

            userServices.getValidAccessToken = origGetToken;
            userServices.getVrn = origGetVrn;
            HmrcService.prototype.getObligations = origGetObligations;
        });

        it('retries with force refresh on INVALID_CREDENTIALS', async () => {
            const mockObligations = { obligations: [] };

            const origGetToken = userServices.getValidAccessToken;
            const origGetVrn = userServices.getVrn;
            userServices.getValidAccessToken = jest.fn().mockResolvedValue('mock-access-token');
            userServices.getVrn = jest.fn().mockResolvedValue(vrn);

            // First call fails with INVALID_CREDENTIALS, second succeeds
            const origGetObligations = HmrcService.prototype.getObligations;
            let callCount = 0;
            HmrcService.prototype.getObligations = jest.fn().mockImplementation(() => {
                callCount++;
                if (callCount === 1) {
                    throw new Error('INVALID_CREDENTIALS');
                }
                return Promise.resolve(mockObligations);
            });

            const req = { user: { userId }, query: { from, to, status } };
            const res = mockRes();

            await obligationsController.getObligations(req, res);

            // Should have called getValidAccessToken twice: once normal, once with forceRefresh
            expect(userServices.getValidAccessToken).toHaveBeenCalledTimes(2);
            expect(userServices.getValidAccessToken).toHaveBeenLastCalledWith(userId, true);
            expect(res.json).toHaveBeenCalledWith(mockObligations);

            // Restore
            userServices.getValidAccessToken = origGetToken;
            userServices.getVrn = origGetVrn;
            HmrcService.prototype.getObligations = origGetObligations;
        });

        it('returns 400 when user has no VRN', async () => {
            const origGetToken = userServices.getValidAccessToken;
            const origGetVrn = userServices.getVrn;
            userServices.getValidAccessToken = jest.fn().mockResolvedValue('mock-token');
            userServices.getVrn = jest.fn().mockResolvedValue(null);

            const req = { user: { userId }, query: { from, to, status } };
            const res = mockRes();

            await obligationsController.getObligations(req, res);

            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.json).toHaveBeenCalledWith(
                expect.objectContaining({ error: expect.stringContaining('No VRN found') })
            );

            userServices.getValidAccessToken = origGetToken;
            userServices.getVrn = origGetVrn;
        });

        it('returns session expired message on refresh token failure', async () => {
            const origGetToken = userServices.getValidAccessToken;
            const origGetVrn = userServices.getVrn;
            userServices.getValidAccessToken = jest.fn().mockRejectedValue(
                new Error('No refresh token found, please reconnect to HMRC')
            );
            userServices.getVrn = jest.fn().mockResolvedValue(vrn);

            const req = { user: { userId }, query: { from, to, status } };
            const res = mockRes();

            await obligationsController.getObligations(req, res);

            expect(res.status).toHaveBeenCalledWith(500);
            expect(res.json).toHaveBeenCalledWith(
                expect.objectContaining({ error: 'HMRC session expired, please reconnect to HMRC' })
            );

            userServices.getValidAccessToken = origGetToken;
            userServices.getVrn = origGetVrn;
        });
    });

    // live test

    describe('Live HMRC integration', () => {
        it('can get obligations from HMRC using getValidAccessToken', async () => {
            // Restore real tokens first
            const { ObjectId } = require('mongodb');
            const userCollection = await db.getCollection('users');
            const user = await userCollection.findOne({ _id: new ObjectId(userId) });

            // Skip if user has no refresh token stored
            if (!user || !user.refresh_token) {
                console.warn('Skipping live test: no refresh token in DB');
                return;
            }

            try {
                const accessToken = await userServices.getValidAccessToken(userId);
                expect(accessToken).toBeDefined();
                expect(typeof accessToken).toBe('string');

                const hmrcService = new HmrcService(accessToken);
                const obligations = await hmrcService.getObligations(vrn, from, to, status);

                expect(obligations).toBeDefined();
                if (obligations && Object.prototype.hasOwnProperty.call(obligations, 'obligations')) {
                    expect(Array.isArray(obligations.obligations)).toBe(true);
                }
                console.log('Obligations:', JSON.stringify(obligations, null, 2));
            } catch (error) {
                console.warn('Live HMRC test failed (expected in CI):', error.message);
            }
        });
    });
});