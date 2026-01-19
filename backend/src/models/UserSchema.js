const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const UserSchema = new Schema({

    password: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true
    },
    vrn: {
        type: String,
        required: true,
    },
    refresh_token: {
        type: String,
        required: true
    },
    token_expiry: {
        type: Date,
        required: true
    },
    hrmc_connected: {
        type: Boolean,
        required: true,
        default: false
    }

});
module.exports = UserSchema;