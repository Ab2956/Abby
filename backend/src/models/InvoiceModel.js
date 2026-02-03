const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const InvoiceSchema = new Schema({

    invoice_number: {
        type: String,
        required: true
    },
    invoice_date: {
        type: Date,
        required: true
    },
    supplier: {
        type: {
            supplier_name: {
                type: String,
                required: true
            },
            supplier_address: {
                type: String,
                required: true
            },
            supplier_contact: {
                type: String
            },
            supplier_vat_number: {
                type: String,
                required: true
            }
        },
        required: true
    },
    customer: {
        type: {
            customer_name: {
                type: String,
                required: true
            },
            customer_address: {
                type: String,
                required: true
            },
        },
        required: true
    },
    items: [{
        description: {
            type: String,
            required: true
        },
        quantity: {
            type: Number,
            required: true
        },
        unit_price: {
            type: Number,
            required: true
        },
        vat_rate: {
            type: Number,
            required: true
        },
        total_price: {
            type: Number,
            required: true
        }
    }],
    total_amount: {
        type: Number,
        required: true
    },

    vat: {
        type: Number,
    },

})
module.exports = mongoose.model('Invoice', InvoiceSchema);