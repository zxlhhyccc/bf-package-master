#!/usr/bin/env node

var fs = require('fs');

process.argv.slice(2).forEach(function(f) {
    process.stdout.write(fs.readFileSync(f, 'utf8'));
});
