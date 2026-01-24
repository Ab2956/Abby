const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const InoviceSchema = new Schema({


    invoice_number: {
        type: String,
        required: true
    },
    invoice_date: {
        type: Date,
        required: true
    },
    total_amount: {
        type: Number,
        required: true
    },

    vat: {
        type: String
    },

})