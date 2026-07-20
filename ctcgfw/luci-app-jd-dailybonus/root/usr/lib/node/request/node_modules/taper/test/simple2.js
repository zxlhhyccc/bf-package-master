
var test = require('tap').test;

test('another simple test', function (t) {
  t.equal(true, true);
  console.error('I will log to stderr here.');
  t.end();
});



