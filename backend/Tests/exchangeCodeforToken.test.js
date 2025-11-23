jest.mock('../src/utils/oauthClient');
const OAuthClient = require('../src/utils/oauthClient');
const authServices = require('../src/services/authServices');

describe('Test exchange token auth', () => {
    let postMock;

    beforeEach(() => {
        postMock = jest.fn();
        OAuthClient.mockImplementation(() => ({ post: postMock }));
    });

    it('exchange code for token', async() => {

        postMock.mockResolvedValue({
            access_token: 'mock-access-token',
            refresh_token: 'mock-refresh-token',
            expires_in: 3600
        });

        const code = 'mock-authorization-code';
        const tokenData = await authServices.getTokenData(code);

        console.log('Token Data:', tokenData);

        expect(tokenData).toEqual({
            access_token: 'mock-access-token',
            refresh_token: 'mock-refresh-token',
            expires_in: 3600
        });
        expect(tokenData.access_token).toBe('mock-access-token');

    });

    it('throw an error for no exchange', async() => {

        postMock.mockRejectedValue(new Error('Network error'));

        const code = 'mock-authorization-code';

        await expect(authServices.getTokenData(code)).rejects.toThrow('Failed: exchange token');
    });
});