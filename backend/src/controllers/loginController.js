const bcrypt = require('bcrypt');
const jwtServices = require('../services/jwtServices');
const userServices = require('../services/userServices');
const dataHandler = require('../database/dataHandler');

async function login(req, res) {
    const { email, password } = req.body;

    try {
        let user = await dataHandler.findUser({ email });

        if (!user) {
            res.send("no user create an account")
        } 
        
        const validPassword = await bcrypt.compare(password, user.password);
        
        if (!validPassword) {
            return res.status(401).json({ error: "Invalid password" });
        }

        const token = jwtServices.createJWT({userId: user._id });
        res.json(token);

    } catch (error) {
        res.status(500).json({ error: "Internal server error" });
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
        res.status(200).json({ message: "Account created successfully" });

    } catch (error) {
        res.status(500).json({ error: "Failed to create account" });
    }
};

module.exports = { createAccount, login, getProfile };