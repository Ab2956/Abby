require("dotenv").config();

const vatService = require("../src/services/vatService");
const bookkeepingDataHandler = require("../src/database/bookkeepingDataHandler");
const invoiceDataHandler = require("../src/database/invoiceDataHandler");
const db = require('../src/database/connectDB');

afterAll(async() => {
    await db.closeConnection();
});

describe("VAT Service Tests", () => {
    const userId = '68fa2057b845e279d8dc41a9';

    test("should calculate total VAT for user", async() => {
        const totalVat = await vatService.calculateTotalVat(userId);
        expect(totalVat).toBeDefined();
        expect(typeof totalVat).toBe("number");
        console.log("Total VAT for User:", totalVat);
    });

    test("should get total vat from recipts", async() => {  
        const totalVatFromRecipts = await bookkeepingDataHandler.getAllVatAmountsByUserId(userId);
        expect(totalVatFromRecipts).toBeDefined();
        expect(typeof totalVatFromRecipts).toBe("number");
        console.log("Total VAT from Recipts:", totalVatFromRecipts);
    });
    
    test("should get total vat from invoices", async() => {  
        const totalVatFromInvoices = await invoiceDataHandler.getAllVatAmountsByUserId(userId);
        expect(totalVatFromInvoices).toBeDefined();
        expect(typeof totalVatFromInvoices).toBe("number"); 
        console.log("Total VAT from Invoices:", totalVatFromInvoices);
    });
});