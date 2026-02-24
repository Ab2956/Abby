require('dotenv').config();
//const dataHandler = require('../src/database/dataHandler');
const userDataHandler = require('../src/database/userDataHandler');
const userServices = require('../src/services/userServices');
const bookkeepingDataHandler = require('../src/database/bookkeepingDataHandler');
const invoiceDataHandler = require('../src/database/invoiceDataHandler');

describe('Data handler tests', () => {
   
    afterEach(() => {
        jest.clearAllMocks();
    });
    

    describe('updateUser', () => {
        it('should update user data successfully', async () => {
            const userId = '68fa2057b845e279d8dc41a9';
            const updateData = { refresh_token: 'new_refresh_token' };
            const mockUpdateUser = jest.spyOn(userDataHandler, 'updateUser').mockResolvedValue({
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

            jest.spyOn(userDataHandler, 'updateUser').mockRejectedValue(mockError);
            await expect(userServices.updateUser(userId, updateData)).rejects.toThrow('Update failed');
        });
    });
    describe('invoiceDataHandler tests', () => {
        it('should add invoice data successfully', async () => {
            const invoiceData = {
                userId: '68fa2057b845e279d8dc41a9',
                invoice_number: 'INV-100123',
                date: '2024-01-01',
                total: 100.00,
                supplier_name: 'Test Supplier',
            };
            const mockAddInvoice = jest.spyOn(invoiceDataHandler, 'addInvoice').mockResolvedValue({
                acknowledged: true,
                insertedId: 'mock_invoice_id',
            });
            const result = await invoiceDataHandler.addInvoice(invoiceData);
            expect(mockAddInvoice).toHaveBeenCalledWith(invoiceData);
            expect(result).toEqual({
                acknowledged: true,
                insertedId: 'mock_invoice_id',
            });
        });
    
        it('should throw an error if adding invoice fails', async () => {
            const invoiceData = {
                userId: '68fa2057b845e279d8dc41a9',
                invoice_number: 'INV-100123',
                date: '2024-01-01',
                total: 100.00,
                supplier_name: 'Test Supplier',
            };
            const mockError = new Error('Add invoice failed');
            jest.spyOn(invoiceDataHandler, 'addInvoice').mockRejectedValue(mockError);
            await expect(invoiceDataHandler.addInvoice(invoiceData)).rejects.toThrow('Add invoice failed');
        }
        );
    });
    describe('bookkeepingDataHandler tests', () => {
        it('should add bookkeeping entry successfully', async () => {
            const entryData = {
                userId: '68fa2057b845e279d8dc41a9',
                description: 'Test entry',
                amount: 50.00,
                date: '2024-01-01',
            };
            const mockAddEntry = jest.spyOn(bookkeepingDataHandler, 'addRecpit').mockResolvedValue({
                acknowledged: true,
                insertedId: 'mock_entry_id',
            });
            const result = await bookkeepingDataHandler.addRecpit(entryData);
            expect(mockAddEntry).toHaveBeenCalledWith(entryData);
            expect(result).toEqual({
                acknowledged: true,
                insertedId: 'mock_entry_id',
            });
        }   
        );
        it('should throw an error if adding entry fails', async () => {
            const entryData = {
                userId: '68fa2057b845e279d8dc41a9',
                description: 'Test entry',
                amount: 50.00,
                date: '2024-01-01',
            };
            const mockError = new Error('Add entry failed');
            jest.spyOn(bookkeepingDataHandler, 'addRecpit').mockRejectedValue(mockError);
            await expect(bookkeepingDataHandler.addRecpit(entryData)).rejects.toThrow('Add entry failed');
        });
    });
});
