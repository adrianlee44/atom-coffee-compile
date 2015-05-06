# coffee-compile package [![Build Status](https://travis-ci.org/adrianlee44/atom-coffee-compile.svg?branch=master)](https://travis-ci.org/adrianlee44/atom-coffee-compile)

Preview, compile and/or save CoffeeScript in editor to Javascript
- Mac: `cmd+shift+c`
- Linux/Windows: `ctrl-alt-c`

## Options
- Compile on save (default: false)
- Compile on save without preview pane (default: false)
- Destination filepath (default: '.')
- Flatten (default: false)
- No top level function wrapper (default: true)
- Focus editor after compile (default: false)
- Compile CJSX (default: false)

![](https://raw.github.com/adrianlee44/atom-coffee-compile/master/screenshot.png)

## TODO
- Recompile on change option
- Open compiled JS in pane if `compile on save` option is enabled
- Add sourcemap support
- Support plugins

## Changelog
- 2015-05-06   v0.14.0   Added `destination filepath` and `flatten` options
- 2015-04-17   v0.13.0   Updated coffee-script to 1.9.2
- 2015-04-09   v0.12.0   Added `Compile CJSX` option (disabled by default)

Check [changelog](https://github.com/adrianlee44/atom-coffee-compile/blob/master/CHANGELOG.md) for more information
