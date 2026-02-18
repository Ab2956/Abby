const monngoose = require('mongoose');
const Schema = monngoose.Schema;

const ReciptSchema = new Schema({
    date: {
        type: Date,
        required: true
    },
    amount: {
        type: Number,
        required: true
    },
    description: {
        type: String,
        required: true
    },
    category: {
        type: String,
        required: true
    }
});
module.exports = monngoose.model('Recipt', ReciptSchema);