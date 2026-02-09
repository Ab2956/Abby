const { MongoClient, ServerApiVersion } = require('mongodb');
const uri = process.env.MONGODB_URI;

const client = new MongoClient(uri, {
    serverApi: {
        version: ServerApiVersion.v1,
        strict: true,
        deprecationErrors: true,
    }
});

let dbInstance = null;
// Connect once and reuse the DB instance
async function createConnection() {
    if (dbInstance) return dbInstance;

    try {
        await client.connect();
        dbInstance = client.db("abby_database");
        return dbInstance;
    } catch (err) {
        console.error("MongoDB connection error:", err);
        throw err;
    }
}
async function closeConnection() {
    await client.close();
    dbInstance = null;
}

async function getCollection(name) {
    const db = await createConnection();
    return db.collection(name);
}

module.exports = { createConnection, getCollection, closeConnection };