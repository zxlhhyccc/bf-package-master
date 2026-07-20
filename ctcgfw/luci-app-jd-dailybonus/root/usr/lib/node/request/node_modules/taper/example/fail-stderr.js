
var test = require('tap').test;

test('failing example which writes to stderr', function (t) {
  t.equal('foo', 'bar', 'purposefully making this fail for example');
  console.error('I will log to stderr here.');
  t.end();
});



