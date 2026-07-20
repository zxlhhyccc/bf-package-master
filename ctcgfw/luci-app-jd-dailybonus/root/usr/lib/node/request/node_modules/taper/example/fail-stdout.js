
var test = require('tap').test;

test('failing example which writes to stdout', function (t) {
  t.equal('cat', 'dog', 'purposefully making this fail for example');
  console.error('I will log to stdout here.');
  t.end();
});

test('successful example', function (t) {
  t.equal(1, 1);
  t.end();
});



