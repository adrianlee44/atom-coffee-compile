# coffee-compile package [![Build Status](https://img.shields.io/travis/adrianlee44/atom-coffee-compile/master.svg?style=flat-square)](https://travis-ci.org/adrianlee44/atom-coffee-compile)

Preview, compile and/or save CoffeeScript in editor to Javascript
- Mac: `cmd+shift+c`
- Linux/Windows: `ctrl-alt-c`

## Options
- `Compile on save` (default: false)
- `Compile on save without preview pane` (default: false)
- `Destination filepath` (default: '.')
- `Flatten` (default: false)
- `cwd` - All sources are relative to this path (default: '.')
- `Source(s)` - Source folders to compile, relative to cwd (default: '.')
- `No top level function wrapper` (default: true)
- `Focus editor after compile` (default: false)
- `Compile CJSX` (default: false)

![](https://raw.github.com/adrianlee44/atom-coffee-compile/master/screenshot.png)

## TODO
- Recompile on change option
- Add sourcemap support

## Changelog
### v0.17.1 (2015-07-27)
- Fix empty preview pane when `compileOnSaveWithoutPreview` is on

### v0.17.0 (2015-07-26)
- Add `cwd` and `source` option for writing to files
  - `cwd` sets the root folder to compile (relative to project root)
  - `source(s)` are folders to compile (relative to cwd)
- Show error notifications when failed to compile to file

See [changelog](https://github.com/adrianlee44/atom-coffee-compile/blob/master/CHANGELOG.md) for more information
