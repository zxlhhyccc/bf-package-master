
var test = require('tap').test;

test('this should fail', function (t) {
  t.equal(true, false);
  console.error('I will log to stderr here.');
  t.end();
});

