#!/usr/bin/env node

var cp     = require('child_process'),
    concat = require('concat-stream'),
    fs     = require('fs'),
    path   = require('path'),
    tape   = require('tape');

var bin = path.join(__dirname, '..', '..', 'bin', 'taper.js');

fs.readdir(path.join(__dirname, '..'), function(err, files) {
    if (err) throw err;

    var toProcess = [];

    files.forEach(function(f) {
        if (/\.(js|coffee|tap)$/.test(f)) {
            processFile(path.join(__dirname, '..', f));
        }
    });
});

function getExpectedFilename(f, k) {
    return path.join(
        path.dirname(f),
        'expected',
        path.basename(f) + '.' + k + '.txt');
}

function removePathsAndLineNumbers(f, s) {
    s = s.toString();

    if (!/\.tap$/.test(f)) {
        s = s
            .replace(new RegExp('/.*/', 'g'), '<FILE_PATH>/')
            .replace(/\d+:\d+(\)?)$/gm, '<LINE:COL>$1');
    }

    return s;
}


function processFile(f) {
    tape(f, function(t) {
        var actual   = {
                stdout : '',
                stderr : ''
            },
            expected = {
                stdout : '',
                stderr : ''
            };

        for (var k in expected) {
            try {
                expected[k] = fs.readFileSync(getExpectedFilename(f, k), 'utf8');
            } catch (err) { }
        }

        expected.fail = /fail/.test(path.basename(f));

        var taper = cp.spawn('node', [bin, '--timeout', '1000', f], { stdio : 'pipe' });
        taper.stdout.pipe(concat(function(stdout) {
            actual.stdout = removePathsAndLineNumbers(f, stdout);
        }));
        taper.stderr.pipe(concat(function(stderr) {
            actual.stderr = removePathsAndLineNumbers(f, stderr);
        }));
        taper.on('close', function(code, signal) {
            if (expected.fail) {
                t.notEqual(code, 0, 'expect test failure');
            } else {
                t.equal(code, 0, 'expect test success');
            }

            if (process.env.SAVE_OUTPUT_AS_EXPECTED) {
                for (var k in actual) {
                    fs.writeFileSync(getExpectedFilename(f, k), actual[k]);
                }
            }

            for (var k in actual) {
                t.equal(actual[k].trim(), expected[k].trim(), k + ' matches expected');
            }

            t.end();
        });
    });
}
