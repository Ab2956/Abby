const bcrypt = require('bcrypt');
const jwtServices = require('../services/jwtServices');
const userServices = require('../services/userServices');
const dataHandler = require('../database/dataHandler');

async function login(req, res) {
    const { email, password } = req.body;

    try {
        let user = await dataHandler.findUser({ email });

        if (!user) {
            return res.status(404).json({ error: "no user create an account" });
        }

        const validPassword = await bcrypt.compare(password, user.password);

        if (!validPassword) {
            return res.status(401).json({ error: "Invalid password" });
        }

        let isConnectedToHmrc = await userServices.isConnectedToHMRC(user._id);

        const token = jwtServices.createJWT({ userId: user._id });
        res.json({ token, isConnectedToHmrc });

    } catch (error) {
        res.status(500).json({ error: "Internal server error" });
    }
};
async function getProfile(req, res) {
    try {
        const user = await dataHandler.findUser({ email: req.user.email });

        if (!user) {
            return res.status(404).json({ error: "User not found" });
        }

        const isConnectedToHmrc = await userServices.isConnectedToHMRC(user._id);
        res.json({ email: user.email, isConnectedToHmrc });
    } catch (error) {
        res.status(500).json({ error: "Internal server error" });
    }
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