const bcrypt = require('bcrypt');
const { getCollection } = require('../database/connectDB');
const jwtServices = require('../services/jwtServices');
const userServices = require('../services/userServices');
const dataHandler = require('../database/dataHandler');
const authController = require('../controllers/authController');

async function login(req, res) {
    const { email, password } = req.body;

    try {
        let user = await dataHandler.findUser({ email });
        if (!user) {
            res.send("no user create an account")
        } else {
            const validPassword = await bcrypt.compare(password, user.password);
            if (!validPassword) {
                return res.status(401);
            }

        }
        const token = jwtServices.createJWT(user.email, user._id.toString());
        res.json({token});

    } catch (error) {
        res.status(500);
    }
};
async function getProfile(req, res) {
    const user = await dataHandler.findUser({ email: req.user.email });

    res.json({ email: user.email });
}


async function createAccount(req, res) {
    const { email, password, vrn } = req.body;
    const userData = { email, password, vrn };

    try {
        userServices.addUser(userData);
        res.status(200);

    } catch (error) {
        throw error;
    }
};

module.exports = { createAccount, login, getProfile };