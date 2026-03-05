const monngoose = require('mongoose');
const Schema = monngoose.Schema;

const ReciptSchema = new Schema({
    vendor: {
        type: String,
        default: ''
    },
    description: {
        type: String,
        default: ''
    },
    date: {
        type: Date,
        required: true
    },
    totalAmount: {
        type: Number,
        default: 0
    },
    vatAmount: {
        type: Number,
        default: 0
    },
    category: {
        type: String,
        default: 'Uncategorised'
    },
    paymentMethod: {
        type: String,
        default: 'Cash'
    },
    isIncome: {
        type: Boolean,
        default: false
    },
    notes: {
        type: String,
        default: ''
    },
    userId: {
        type: Schema.Types.ObjectId,
        required: true
    }
});
module.exports = monngoose.model('Recipt', ReciptSchema);