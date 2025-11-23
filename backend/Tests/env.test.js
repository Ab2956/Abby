require('dotenv').config();

console.log('JWT_SECRET:', process.env.JWT_SECRET);

test('env works', () => {
  console.log(process.env.CLIENT_ID
  )
  expect(process.env.JWT_SECRET).toBeDefined();
});