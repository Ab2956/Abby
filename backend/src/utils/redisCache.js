// const redis = require('redis');
// const client = redis.createClient({
//     socket: {
//         host: process.env.REDIS_HOST || 'localhost',
//         port: process.env.REDIS_PORT || 6379
//     }
// });
// client.on('error', (err) => console.error('Redis error:', err));

// (async () => {
//     try {
//         await client.connect();
//         console.log('Connected to Redis');
//     } catch (err) {
//         console.error('Redis connection error:', err);
//     }
// })();

//     module.exports = {
//         set: async (state, userId, expires_in = 600) => {
//             await client.setEx(`oauth:${state}`, expires_in, userId);

//     },
//         get: async (state) => {
//             return await client.get(`oauth:${state}`);
//         },
//         delete: async (state) => {
//             await client.del(`oauth:${state}`);
//         }
// };
// Simple in-memory cache (no Redis server needed)
const cache = new Map();

// Cleanup expired entries every minute
setInterval(() => {
    const now = Date.now();
    for (const [key, value] of cache.entries()) {
        if (value.expiresAt < now) {
            cache.delete(key);
            console.log(`⏰ Auto-cleaned expired state: ${key}`);
        }
    }
}, 60000);

module.exports = {
    set: async (state, userId, expires_in = 600) => {
        cache.set(state, {
            userId,
            expiresAt: Date.now() + (expires_in * 1000)
        });
        console.log(`✅ Cached state: ${state} → userId: ${userId}`);
    },
    
    get: async (state) => {
        const data = cache.get(state);
        if (!data) {
            console.log(`❌ State not found: ${state}`);
            return null;
        }
        
        if (Date.now() > data.expiresAt) {
            cache.delete(state);
            console.log(`⏰ Expired state: ${state}`);
            return null;
        }
        
        console.log(`✅ Retrieved state: ${state} → userId: ${data.userId}`);
        return data.userId;
    },
    
    delete: async (state) => {
        const deleted = cache.delete(state);
        console.log(`🗑️ Deleted state: ${state} (${deleted ? 'success' : 'not found'})`);
    }
};

