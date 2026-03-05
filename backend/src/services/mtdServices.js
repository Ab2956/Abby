
const QUARTER_PERIODS = {
        1:{ start: '04-06', end: '07-05' },
        2:{ start: '07-06', end: '10-05' },
        3:{ start: '10-06', end: '01-05' },
        4:{ start: '01-06', end: '04-05' }
    };

class MtdServices {

    getPeriodDates(quarter, taxYear) {
        const period = QUARTER_PERIODS[quarter];
        if (!period) {
            throw new Error(`Invalid quarter: ${quarter}. Must be 1-4.`);
        }

        const startYear = quarter >= 4 ? taxYear + 1 : taxYear;
        const endYear = quarter >= 3 ? taxYear + 1 : taxYear;

        return {
            from: `${startYear}-${period.start}`,
            to: `${endYear}-${period.end}`,
        };
    }

    formatForHmrc(data) {
        if (!data || typeof data !== 'object') {
            throw new Error('Invalid data format');
        }

        // Build periodIncome
        const periodIncome = {
            turnover: this.roundAmount(data.turnover || 0),
            other: this.roundAmount(data.otherIncome || 0),
        };

        // Build periodExpenses with HMRC's exact categories
        const periodExpenses = {};
        for (const category of VALID_EXPENSE_CATEGORIES) {
            const expense = data.expenses?.[category];
            if (expense) {
                periodExpenses[category] = {
                    amount: this.roundAmount(expense.amount || 0),
                    disallowableAmount: this.roundAmount(expense.disallowableAmount || 0),
                };
            }
        }

        // Warn about unrecognised categories
        if (data.expenses) {
            const unknownCategories = Object.keys(data.expenses)
                .filter(key => !VALID_EXPENSE_CATEGORIES.includes(key));
            if (unknownCategories.length > 0) {
                console.warn(
                    `Unknown expense categories ignored: ${unknownCategories.join(', ')}. ` +
                    `These must be mapped to HMRC categories.`
                );
            }
        }

        return { periodIncome, periodExpenses };
    }
    roundAmount(value) {
        const num = Number(value);
        if (isNaN(num) || num < 0) {
            throw new Error(`Invalid amount: ${value}. Must be a non-negative number.`);
        }
        return Math.round(num * 100) / 100;
    }

    async uploadQuarterData(userId, data) {
        // Process the data and store it in the database
  
        try {
            // Validate the data
            if (quarter < 1 || quarter > 4) {
                throw new Error('Invalid quarter. Must be between 1 and 4.');
            }
            const periodDates = this.getPeriodDates(quarter, taxYear);
            const formattedData = this.formatForHmrc(data);

            const submission = {
                userId,
                quarter,
                taxYear,
                ...periodDates,
                ...formattedData,
                submittedAt: new Date().toISOString(),
            };

            return { message: 'Data uploaded successfully' };
        }
        catch (error) {
            console.error('Error uploading data:', error);
            throw new Error('Failed to upload data');
        }   
    }
    
}