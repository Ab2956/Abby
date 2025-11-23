const bcrypt = require('bcrypt');
const { getCollection } = require('../database/connectDB');
const jwtServices = require('../services/jwtServices');

async function login(req, res) {
    const { email, password } = req.body;

    try {
        const users = await getCollection('users');
        let user = await users.findOne({ email });
        if (!user) {
            res.send("no user create an account")
        } else {
            const validPassword = await bcrypt.compare(password, user.password);
            if (!validPassword) {
                return res.status(401);
            }

        }
        const token = jwtServices.createJWT(user.userId);
        res.json(token);

    } catch (error) {
        res.status(500);
    }
};
async function getProfile(req, res) {
    const users = getCollection('users');
    const user = await users.findOne({ email: req.user.email });

    res.json({ email: user.email });
}
async function createAccount(req, res) {
    const { email, password } = req.body;

    try {

    } catch (error) {

    }



};

module.exports = { createAccount, login, getProfile };