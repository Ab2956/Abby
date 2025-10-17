const axios = require('axios');
const { getTokenData } = require('../src/services/authServices');

jest.mock('axios');

describe('Test exchange token auth', () => {
  it('exchange code for token', async () => {

    axios.post.mockResolvedValue({
      data: {
        access_token: 'mock-access-token',
        refresh_token: 'mock-refresh-token',
        expires_in: 3600
      }
    });

    const code = 'mock-authorization-code';
    const tokenData = await getTokenData(code);

    console.log('Token Data:', tokenData)

    expect(tokenData).toEqual({
      access_token: 'mock-access-token',
      refresh_token: 'mock-refresh-token',
      expires_in: 3600
    });
    expect(axios.post).toHaveBeenCalledWith(
      'https://test-api.service.hmrc.gov.uk/oauth/token',
      expect.objectContaining({
        grant_type: 'authorization_code',
        client_id: process.env.CLIENT_ID,
        client_secret: process.env.CLIENT_SECRET,
        redirect_uri: process.env.REDIRECT_URI,
        code: 'mock-authorization-code'
      })
    );
  });

  it('throw an error for no exchange', async () => {

    axios.post.mockRejectedValue(new Error('Network error'));

    const code = 'mock-authorization-code';

    await expect(getTokenData(code)).rejects.toThrow('Failed: exchange token');
  });
});
