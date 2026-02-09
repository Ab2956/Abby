class ExtractionHelper {

    
    extractInvoiceNumber(text) {
        const patterns = [
            /Invoice\s*Number[:\s]+(\S+)/i,
            /Invoice\s*No\.?[:\s]+(\S+)/i,
            /Invoice\s*#[:\s]*(\S+)/i,
            /INV[:\s-]+(\S+)/i,
            /Inv\s*(?:No|Number)[:\s]+(\S+)/i
        ];
        return  this.tryPatterns(text, patterns);
    }

    
    extractDate(text) {
        const patterns = [
            /Invoice\s*Date[:\s]+([\d\s\w\/\-]+?)(?=\n|Supply)/i,
            /Date\s*of\s*Issue[:\s]+([\d\s\w\/\-]+)/i,
            /Date[:\s]+([\d\s\w\/\-]+)/i,
            /Issued[:\s]+([\d\s\w\/\-]+)/i
        ];
        const dateStr =  this.tryPatterns(text, patterns);
        return dateStr ? new Date(dateStr.trim()) : null;
    }

    
    extractSupplierName(text) {
        const patterns = [
            /Supplier[:\s]*\n\s*([^\n]+)/i,
            /From[:\s]+([^\n]+)/i,
            /Supplier\s*Name[:\s]+([^\n]+)/i,
            /Vendor[:\s]+([^\n]+)/i,
            /INVOICE\s*\n\s*Supplier[:\s]*\n\s*([^\n]+)/i
        ];
        return ( this.tryPatterns(text, patterns))?.trim();
    }

    
    extractSupplierAddress(text) {
        const patterns = [
            /Supplier\s*Address[:\s]+([^\n]+(?:\n[^\n]+)*?)(?=\n\s*(?:VAT|Billed|Customer|Invoice))/is,
            /Supplier[:\s]*\n\s*[^\n]+\n\s*(.+?)\n\s*(.+?)\n\s*(.+?)(?=\n\s*VAT)/is,
            /Address[:\s]+([^\n]+)/i
        ];
        
        const match = text.match(patterns[1]);
        if (match) {
            return `${match[1].trim()}, ${match[2].trim()}, ${match[3].trim()}`;
        }
        
        return  this.tryPatterns(text, [patterns[0], patterns[2]])?.trim();
    }

    
    extractSupplierContact(text) {
        const patterns = [
            /Supplier\s*Contact[:\s]+([^\n]+)/i,
            /(?:Phone|Tel|Contact)[:\s]+([^\n]+)/i,
            /Email[:\s]+([^\n]+)/i,
            /Bank[:\s]+([^|]+)/i
        ];
        return ( this.tryPatterns(text, patterns))?.trim();
    }

    
    extractSupplierVat(text) {
        const patterns = [
            /VAT\s*No\.?[:\s]+(\S+)/i,
            /Supplier\s*VAT\s*Number[:\s]+(\S+)/i,
            /VAT\s*(?:Number|Registration)[:\s]+(\S+)/i,
            /Tax\s*ID[:\s]+(\S+)/i
        ];
        return  this.tryPatterns(text, patterns);
    }

    
    extractCustomerName(text) {
        const patterns = [
            /Billed\s*To[:\s]*\n\s*([^\n]+)/i,
            /Customer\s*Name[:\s]+([^\n]+)/i,
            /Bill\s*To[:\s]+([^\n]+)/i,
            /Client[:\s]+([^\n]+)/i,
            /To[:\s]+([^\n]+)/i
        ];
        return ( this.tryPatterns(text, patterns))?.trim();
    }

    
    extractCustomerAddress(text) {
        const patterns = [
            /Customer\s*Address[:\s]+([^\n]+(?:\n[^\n]+)*?)(?=\n\s*Invoice)/is,
            /Billed\s*To[:\s]*\n\s*[^\n]+\n\s*(.+?)\n\s*(.+?)\n\s*(.+?)(?=\n\s*Invoice)/is,
            /Bill\s*To\s*Address[:\s]+([^\n]+)/i
        ];
        
        const match = text.match(patterns[1]);
        if (match) {
            return `${match[1].trim()}, ${match[2].trim()}, ${match[3].trim()}`;
        }
        
        return ( this.tryPatterns(text, [patterns[0], patterns[2]]))?.trim();
    }

    
    extractItems(text) {
        const items = [];
        
        const formats = [
            /Item\s*Description[:\s]+(.+?)\s*Quantity[:\s]+(\d+)\s*Unit\s*Price[:\s]+([\d\.]+)\s*VAT\s*Rate[:\s]+([\d\.]+)%?\s*Total\s*Price[:\s]+([\d\.]+)/gi,
            /^([A-Za-z\s]+?)\s+(\d+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)$/gm,
            /(.+?)\s*\n.*?(\d+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)/g
        ];

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
                        vat_rate: 20, 
                        total_price: parseFloat(match[6])
                    });
                }
            }
        }

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
        const amount =  this.tryPatterns(text, patterns);
        return amount ? parseFloat(amount.replace(/,/g, '')) : null;
    }

    
    extractVat(text) {
        const patterns = [
            /VAT\s*\([\d]+%\)[:\s]+£?([\d,\.]+)/i,
            /VAT\s*Amount[:\s]+£?([\d,\.]+)/i,
            /Tax\s*Amount[:\s]+£?([\d,\.]+)/i,
            /VAT[:\s]+£?([\d,\.]+)/i
        ];
        const vat =  this.tryPatterns(text, patterns);
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

module.exports = new ExtractionHelper();