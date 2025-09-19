const authServices = require('../services/authServices');

exports.login = (req, res) => {
    res.redirect(authServices.url());
};

exports.callback = async (req, res) => {
    const {code} = req.query;
    await authServices.exchangeForToken(code);
    res.redirect('/home');
}