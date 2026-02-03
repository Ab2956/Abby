const InvoiceParser = require('./invoiceParser');
const pdf = require('pdf-parse');
const invoiceSchema = require('../models/InvoiceModel');

class PdfParser extends InvoiceParser {

    async parseFile(buffer) {
        try {
            const data = await pdf(buffer);
            const text = data.text || data.textContent;

             console.log('PDF Text:', text);

            const invoice = new invoiceSchema({

               invoice_number: this.extractInvoiceNumber(text),
                invoice_date: this.extractDate(text),
                supplier: {
                    supplier_name: this.extractSupplierName(text),
                    supplier_address: this.extractSupplierAddress(text),
                    supplier_contact: this.extractSupplierContact(text),
                    supplier_vat_number: this.extractSupplierVat(text)
                },
                customer: {
                    customer_name: this.extractCustomerName(text),
                    customer_address: this.extractCustomerAddress(text)
                },
                items: this.extractItems(text),
                total_amount: this.extractTotalAmount(text),
                vat: this.extractVat(text)
            });
            console.log('Extracted Data:', JSON.stringify(invoice, null, 2));
            await invoice.validate();
            
            return invoice;

        } catch (error) {
            throw new Error(`PDF parsing failed: ${error.message}`);
        }
    }

    extractInvoiceNumber(text) {
        const patterns = [
            /Invoice\s*Number[:\s]+(\S+)/i,
            /Invoice\s*No\.?[:\s]+(\S+)/i,
            /Invoice\s*#[:\s]*(\S+)/i,
            /INV[:\s-]+(\S+)/i,
            /Inv\s*(?:No|Number)[:\s]+(\S+)/i
        ];
        return this.tryPatterns(text, patterns);
    }

    extractDate(text) {
        const patterns = [
            /Invoice\s*Date[:\s]+([\d\s\w\/\-]+?)(?=\n|Supply)/i,
            /Date\s*of\s*Issue[:\s]+([\d\s\w\/\-]+)/i,
            /Date[:\s]+([\d\s\w\/\-]+)/i,
            /Issued[:\s]+([\d\s\w\/\-]+)/i
        ];
        const dateStr = this.tryPatterns(text, patterns);
        return dateStr ? new Date(dateStr.trim()) : null;
    }

    extractSupplierName(text) {
        const patterns = [
            /Supplier[:\s]*\n\s*([^\n]+)/i,
            /From[:\s]+([^\n]+)/i,
            /Supplier\s*Name[:\s]+([^\n]+)/i,
            /Vendor[:\s]+([^\n]+)/i,
            // Extract company name after INVOICE header
            /INVOICE\s*\n\s*Supplier[:\s]*\n\s*([^\n]+)/i
        ];
        return this.tryPatterns(text, patterns)?.trim();
    }

    extractSupplierAddress(text) {
        const patterns = [
            /Supplier\s*Address[:\s]+([^\n]+(?:\n[^\n]+)*?)(?=\n\s*(?:VAT|Billed|Customer|Invoice))/is,
            // Multi-line address after supplier name
            /Supplier[:\s]*\n\s*[^\n]+\n\s*(.+?)\n\s*(.+?)\n\s*(.+?)(?=\n\s*VAT)/is,
            /Address[:\s]+([^\n]+)/i
        ];
        
        const match = text.match(patterns[1]);
        if (match) {
            return `${match[1].trim()}, ${match[2].trim()}, ${match[3].trim()}`;
        }
        
        return this.tryPatterns(text, [patterns[0], patterns[2]])?.trim();
    }

    extractSupplierContact(text) {
        const patterns = [
            /Supplier\s*Contact[:\s]+([^\n]+)/i,
            /(?:Phone|Tel|Contact)[:\s]+([^\n]+)/i,
            /Email[:\s]+([^\n]+)/i,
            /Bank[:\s]+([^|]+)/i
        ];
        return this.tryPatterns(text, patterns)?.trim();
    }

    extractSupplierVat(text) {
        const patterns = [
            /VAT\s*No\.?[:\s]+(\S+)/i,
            /Supplier\s*VAT\s*Number[:\s]+(\S+)/i,
            /VAT\s*(?:Number|Registration)[:\s]+(\S+)/i,
            /Tax\s*ID[:\s]+(\S+)/i
        ];
        return this.tryPatterns(text, patterns);
    }

    extractCustomerName(text) {
        const patterns = [
            /Billed\s*To[:\s]*\n\s*([^\n]+)/i,
            /Customer\s*Name[:\s]+([^\n]+)/i,
            /Bill\s*To[:\s]+([^\n]+)/i,
            /Client[:\s]+([^\n]+)/i,
            /To[:\s]+([^\n]+)/i
        ];
        return this.tryPatterns(text, patterns)?.trim();
    }

    extractCustomerAddress(text) {
        const patterns = [
            /Customer\s*Address[:\s]+([^\n]+(?:\n[^\n]+)*?)(?=\n\s*Invoice)/is,
            // Multi-line address after customer name
            /Billed\s*To[:\s]*\n\s*[^\n]+\n\s*(.+?)\n\s*(.+?)\n\s*(.+?)(?=\n\s*Invoice)/is,
            /Bill\s*To\s*Address[:\s]+([^\n]+)/i
        ];
        
        const match = text.match(patterns[1]);
        if (match) {
            return `${match[1].trim()}, ${match[2].trim()}, ${match[3].trim()}`;
        }
        
        return this.tryPatterns(text, [patterns[0], patterns[2]])?.trim();
    }

    extractItems(text) {
        const items = [];
        
        // Try different table formats
        const formats = [
            // Format 1: Labeled fields
            /Item\s*Description[:\s]+(.+?)\s*Quantity[:\s]+(\d+)\s*Unit\s*Price[:\s]+([\d\.]+)\s*VAT\s*Rate[:\s]+([\d\.]+)%?\s*Total\s*Price[:\s]+([\d\.]+)/gi,
            // Format 2: Table columns
            /^([A-Za-z\s]+?)\s+(\d+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)$/gm,
            // Format 3: Description on separate line
            /(.+?)\s*\n.*?(\d+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)/g
        ];

        // Try format 2 (table) - matches your PDF
        const tableSection = text.match(/Description.*?\n(.*?)(?=Subtotal|Total|Payment)/is);
        if (tableSection) {
            const lines = tableSection[1].trim().split('\n');
            for (const line of lines) {
                const match = line.match(/^(.+?)\s+(\d+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)/);
                if (match) {
                    items.push({
                        description: match[1].trim(),
                        quantity: parseInt(match[2], 10),
                        unit_price: parseFloat(match[3]),
                        vat_rate: 20, // Default or extract from column headers
                        total_price: parseFloat(match[6])
                    });
                }
            }
        }

        // Fallback: try other formats
        if (items.length === 0) {
            for (const format of formats) {
                let match;
                while ((match = format.exec(text)) !== null) {
                    items.push({
                        description: match[1].trim(),
                        quantity: parseInt(match[2], 10),
                        unit_price: parseFloat(match[3]),
                        vat_rate: parseFloat(match[4]) || 20,
                        total_price: parseFloat(match[5] || match[6])
                    });
                }
                if (items.length > 0) break;
            }
        }

        return items;
    }

    extractTotalAmount(text) {
        const patterns = [
            /Total\s*Due[:\s]+£?([\d,\.]+)/i,
            /Total\s*Amount[:\s]+£?([\d,\.]+)/i,
            /Grand\s*Total[:\s]+£?([\d,\.]+)/i,
            /Amount\s*Due[:\s]+£?([\d,\.]+)/i,
            /Total[:\s]+£?([\d,\.]+)/i
        ];
        const amount = this.tryPatterns(text, patterns);
        return amount ? parseFloat(amount.replace(/,/g, '')) : null;
    }

    extractVat(text) {
        const patterns = [
            /VAT\s*\([\d]+%\)[:\s]+£?([\d,\.]+)/i,
            /VAT\s*Amount[:\s]+£?([\d,\.]+)/i,
            /Tax\s*Amount[:\s]+£?([\d,\.]+)/i,
            /VAT[:\s]+£?([\d,\.]+)/i
        ];
        const vat = this.tryPatterns(text, patterns);
        return vat ? parseFloat(vat.replace(/,/g, '')) : null;
    }

    // Helper method to try multiple patterns
    tryPatterns(text, patterns) {
        for (const pattern of patterns) {
            const match = text.match(pattern);
            if (match) {
                return match[1];
            }
        }
        return null;
    }
}

module.exports = { PdfParser };