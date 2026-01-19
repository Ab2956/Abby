require('dotenv').config();
const dataHandler = require('../src/database/dataHandler');
const userServices = require('../src/services/userServices');
const connectDB = require('../src/database/connectDB');

describe('User Services', () => {
    beforeAll(() => {
        connectDB.createConnection();
    });
    afterEach(() => {
        jest.clearAllMocks();
    });
    afterAll(async () => {
        await connectDB.closeConnection();
    });


    describe('updateUser', () => {
        it('should update user data successfully', async () => {
            const userId = '68fa2057b845e279d8dc41a9';
            const updateData = { refresh_token: 'new_refresh_token' };
            const mockUpdateUser = jest.spyOn(dataHandler, 'updateUser').mockResolvedValue({
                acknowledged: true,
                modifiedCount: 1,
            });

            const result = await userServices.updateUser(userId, updateData);   
            expect(mockUpdateUser).toHaveBeenCalledWith(userId, updateData);
            expect(result).toEqual({
                acknowledged: true,
                modifiedCount: 1,
            });
        });
        it('should throw an error if update fails', async () => {
            const userId = '68fa2057b845e279d8dc41a9';
            const updateData = { refresh_token: 'new_refresh_token' };
            const mockError = new Error('Update failed');

            jest.spyOn(dataHandler, 'updateUser').mockRejectedValue(mockError);
            await expect(userServices.updateUser(userId, updateData)).rejects.toThrow('Update failed');
        });
    });
});
