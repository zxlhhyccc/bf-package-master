# taper [![Build status](https://img.shields.io/travis/nylen/taper.svg?style=flat)](https://travis-ci.org/nylen/taper) [![npm package](http://img.shields.io/npm/v/taper.svg?style=flat)](https://www.npmjs.org/package/taper)

Taper (a fork of [`tapr`](https://github.com/jeffbski/tapper)) is a Node.js tap
test runner which allows stdout and stderr mixed in with the tap output. Also
taper adds color to the output. Core based on Isaac Z Schlueter original tap
runner.

For a nice description of Node.js Tap tests, see Isaac's readme on the
[`node-tap` github page](https://github.com/isaacs/node-tap).

Isaac designed his Tap implementation to be modular for easy consumation and
extension. Taper customizes the runner component and uses the rest of node-tap
as is.

Because Tap is modular, it is designed to be consumed in many ways (like
automated build tools, customized runners) and other testing frameworks can
provide producers to provide tap input.



## Goals

 - More concise formatting of tap output (easier to find what you care about)
 - Improve ability to write to stdout and stderr from tests or code
 - Add optional colorized output

## Installing

```bash
npm install taper  # install locally
# OR
npm install -g taper  # install globally
```

**OR**

Add to your project package.json:

```javascript
"devDependencies" : {
  "taper" : "~0.2.0"
}
```

Also you will want to add a tap reporter as a `devDependency` to use in your
tests.  Try [`tap`](https://github.com/isaacs/node-tap) or
[`tape`](https://github.com/substack/tape).

Then `npm install` your package with dev dependencies from the project
directory:

```bash
npm install
```

## Usage

```bash
  node_modules/.bin/taper.js fileOrDir   # if installed locally
  #OR
  taper fileOrDir  # if installed globally
  #
  taper                                     # display usage
  taper --help                         # display usage
  taper --version                    # display version
  taper --no-color fileOrDir   # run without color output
```

## Screenshots

### Successful example where all tests are passing

Stderr and stdout is muted except for files which have a failing test

![success-taper](https://raw.githubusercontent.com/nylen/taper/master/doc/success-taper.png)

### Failure example with some failures and stdout

 - Green - successful tests and files
 - Red - failed tests and files
 - Blue - test names

![failed-taper](https://raw.githubusercontent.com/nylen/taper/master/doc/failed-taper.png)

### Original tap runner success

![success-tap](https://raw.githubusercontent.com/nylen/taper/master/doc/success-tap.png)

### Original tap runner failure

![failed-tap](https://raw.githubusercontent.com/nylen/taper/master/doc/failed-tap.png)

## Limitations

 - stdout logging that looks like tap output (ok, not ok, #) will not be
   displayed unless errors in file, however all stderr logging will be
   displayed regardless so it is recommended.
 - stdout/stderr appears before the test names and asserts due to how tap
   currently outputs data
 - Asserts are summarized at the bottom

## License

 - [MIT license](https://raw.githubusercontent.com/nylen/taper/master/LICENSE)

## Contributors

 - Original code Isaac Z. Schlueter <i@izs.me> http://blog.izs.me
 - [`tapr`](https://github.com/jeffbski/tappper) by author: Jeff Barczewski (@jeffbski)
 - James Nylen (@nylen)

## Contributing

 - Source code repository: https://github.com/nylen/taper
 - Ideas and pull requests are encouraged  - https://github.com/nylen/taper/issues
