
var test = require('tap').test;

var obj = { };

test('failing example which throws', function (t) {
  obj.boom(); //throws TypeError since boom is not a method of obj
  t.ok(true);
  t.end();
});



