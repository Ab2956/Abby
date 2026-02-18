require("dotenv").config();

const BookkeepingService = require("../src/services/bookkeepingServices");
const bookkeepingService = new BookkeepingService();
const ReciptSchema = require("../src/models/BookkeepingModel")
const db = require('../src/database/connectDB');


afterEach(async() => {
    const reciptCollection = await db.getCollection('recipts');
    await reciptCollection.deleteMany({ description: "Test1 recipt" });
});
afterAll(async() => {
    await db.closeConnection();
});

describe("Bookkeeping Tests", () => {
    const userId = '68fa2057b845e279d8dc41a9';
    const recipt = new ReciptSchema({
        date: "2024-06-01",
        amount: 100,
        description: "Test1 recipt",
        category: "Test category"
    });

    const reciptData = recipt.toObject();

    test("should add recipt to db", async() => {
            const result = await bookkeepingService.addRecipt(userId, reciptData);
            expect(result).toBeDefined();
            expect(result.insertedId).toBeDefined();
            const recipts = await bookkeepingService.getRecipts(userId);

            const addedRecipt = recipts.find(inv => inv._id.toString() === result.insertedId.toString());
            expect(addedRecipt.userId.toString()).toBe(userId);
        }),

        test("should get all recipts from db", async() => {
            await bookkeepingService.addRecipt(userId, reciptData);
            const recipts = await bookkeepingService.getRecipts(userId);

            expect(recipts).toBeDefined();
            expect(Array.isArray(recipts)).toBe(true);
            expect(recipts.length).toBeGreaterThan(0);
        });

    test("should delete recipt from db", async() => {
        const addResult = await bookkeepingService.addRecipt(userId, reciptData);
        expect(addResult).toBeDefined();
        expect(addResult.insertedId).toBeDefined();

        const deleteResult = await bookkeepingService.deleteRecipt(addResult.insertedId);
        expect(deleteResult).toBeDefined();
        expect(deleteResult.deletedCount).toBe(1);

    });
});