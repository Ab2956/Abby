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
    // vrn: {
    //     type: String,
    //     required: true,
    // },
    // role: {
    //     type: String,
    //     required: true
    // },
    refresh_token: {
        type: String,
        required: true
    },
    token_expiry: {
        type: Date,
        required: true
    }
});
module.exports = UserSchema;