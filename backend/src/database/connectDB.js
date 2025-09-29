const { MongoClient, ServerApiVersion } = require('mongodb');
const uri = "mongodb+srv://abrows_db:iLX5GvZZv9JbCgg8@abby-cluster.bzck6hi.mongodb.net/?retryWrites=true&w=majority&appName=abby-cluster";

const client = new MongoClient(uri, {
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true,
    deprecationErrors: true,
  }
});

// connection to database.
async function run() {
  try {
    await client.connect();
    await client.db("admin").command({ ping: 1 });
    console.log("Connected to database...")
  } finally {

    await client.close();
  }
}
run().catch(console.dir);
