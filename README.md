# coffee-compile package [![Build Status](https://travis-ci.org/adrianlee44/atom-coffee-compile.svg?branch=master)](https://travis-ci.org/adrianlee44/atom-coffee-compile)

Preview and/or save compiled Javascript in Atom
- Mac: `cmd+shift+c`
- Linux/Windows: `ctrl-alt-c`

## Options
- No top level function wrapper (default: true)
- Compile on save (default: false)
- Compile on save without preview pane (default: false)
- Focus editor after compile (default: false)

![](https://raw.github.com/adrianlee44/atom-coffee-compile/master/screenshot.png)

## TODO
- Recompile on change option
- Open compiled JS in pane if `compile on save` option is enabled
- Add sourcemap support

## Changelog
- 2015-01-24   v0.9.0   Updated to using Atom 1.0 API
- 2014-10-27   v0.8.4   Reenabled focusing on editor. Cleaned up package.
- 2014-10-22   v0.8.3   Fixed preview not working due to API changes
- 2014-09-16   v0.8.2   Added check to make sure user is compiling and saving Coffeescript
- 2014-09-16   v0.8.1   Fixed not able to compile and save when opening a preview pane
- 2014-09-16   v0.8.0   Added `compile on save without preview` feature (disabled by default)
- 2014-09-14   v0.7.0   Fixed compile on save and updated calback API
- 2014-08-29   v0.6.0   Updated CoffeeCompile to support Atom's new ReactEditor
- 2014-08-17   v0.5.0   Converted compiled view to editor which brings line numbers and code selection
- 2014-06-22   v0.4.0   Added keybinding for Linux and Windows
- 2014-04-24   v0.3.2   Fixed horizontal scrolling
- 2014-04-08   v0.3.1   Added `focus editor after compile` option (disabled by default)
- 2014-03-25   v0.3.0   Added `compile on save` feature (disabled by default)
- 2014-03-11   v0.2.1   Compiled view style now matches editor style
- 2014-03-10   v0.2.0   Litcoffee support, Top-level wrapper function option, Grammar config option
- 2014-03-09   v0.1.4   Fixed spliting pane in certain pane arrangement breaks Atom
- 2014-03-07   v0.1.3   Fixed view breaking with jshint
- 2014-03-01   v0.1.2   Code cleanup
- 2014-03-01   v0.1.1   Fixed README screenshot
- 2014-03-01   v0.1.0   Initial Release
