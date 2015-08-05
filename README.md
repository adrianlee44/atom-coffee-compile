# coffee-compile package [![Build Status](https://img.shields.io/travis/adrianlee44/atom-coffee-compile/master.svg?style=flat-square)](https://travis-ci.org/adrianlee44/atom-coffee-compile)

Preview, compile and/or save CoffeeScript in editor to Javascript
- Mac: `cmd+shift+c`
- Linux/Windows: `ctrl-alt-c`

## Options
- `Enable project based configuration` (default: false)
- `Compile on save` (default: false)
- `Compile on save without preview pane` (default: false)
- `Destination filepath` (default: '.')
- `Flatten` (default: false)
- `cwd` - All sources are relative to this path (default: '.')
- `Source(s)` - Source folders to compile, relative to cwd (default: '.')
- `No top level function wrapper` (default: true)
- `Focus editor after compile` (default: false)
- `Compile CJSX` (default: false)

### Project based configuration
Add `coffee-compile.cson` to the project root

See [wiki](https://github.com/adrianlee44/atom-coffee-compile/wiki/Project-based-configuration) for more details

![](https://raw.github.com/adrianlee44/atom-coffee-compile/master/screenshot.png)

## TODO
- Recompile on change option
- Add sourcemap support

## Changelog
See [changelog](https://github.com/adrianlee44/atom-coffee-compile/blob/master/CHANGELOG.md) for more information
