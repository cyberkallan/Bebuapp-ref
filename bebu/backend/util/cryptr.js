const Cryptr = require("cryptr");

// Symmetric key for admin passwords stored in the Admin collection. Set
// ADMIN_PASSWORD_KEY once at install time (install.sh does) and never change it
// afterwards: existing admin passwords would stop decrypting.
const key = process.env.ADMIN_PASSWORD_KEY || "myTotallySecretKey";

module.exports = new Cryptr(key);
