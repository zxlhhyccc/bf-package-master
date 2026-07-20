
var test = require('tap').test;

test('simple test', function (t) {
  console.log('this should be logged to stdout');
  console.error('this should go to stderr');
  t.ok(true);
  t.equal(true, true);
  setTimeout(function() {
    t.end();
  }, 100);
});


test('another simple test', function (t) {
  t.plan(2);
  console.log('more logging to stdout');
  console.error('another log to stderr');
  t.ok(true);
  t.equal('foo', 'foo');
  setTimeout(function() {
    t.end();
  }, 100);
});

test('showing some deeper stderr logging by inspect on tap.test', function (t) {
  console.error('on stderr:', t.conf);
  t.ok(true);
  t.equal('foo', 'foo');
  setTimeout(function() {
    t.end();
  }, 100);
});

test('showing some deeper stdout logging by inspect on tap.test', function (t) {
  console.log('on stdout:', t.conf);
  t.ok(true);
  t.equal('foo', 'foo');
  setTimeout(function() {
    t.end();
  }, 100);
});

