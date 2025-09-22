require('dotenv').config();

console.log('JWT_SECRET:', process.env.JWT_SECRET);

test('env works', () => {
  expect(process.env.JWT_SECRET).toBeDefined();
});