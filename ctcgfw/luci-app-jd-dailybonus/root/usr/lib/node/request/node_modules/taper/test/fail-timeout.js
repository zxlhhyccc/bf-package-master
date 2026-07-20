
var test = require('tap').test;

test('this should timeout', function (t) {
  t.equal(true, true);
  console.error('I will log to stderr here and then never complete.');
});

