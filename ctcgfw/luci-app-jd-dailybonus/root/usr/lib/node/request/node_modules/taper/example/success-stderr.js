
var test = require('tap').test;

test('successful example with stderr', function (t) {
  //This stderr output will not display in the taper output unless this
  //file has at least one failing test. Makes it easy to ignore output
  //except when you care about it.
  console.error('this will not display unless a failure occurs in page');
  t.equal(1, 1);
  t.end();
});




