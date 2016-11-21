## v0.24.0 (2016-11-21)
- Update CoffeeScript to v1.11.1
- Update season to 5.4.1
- Removing cjsx support and removing package

#### Breaking changes:
As coffee-react-transform is now deprecated, this package is dropping
support for cjsx and will not be able to compile those coffee files
properly. If user is still compiling cjsx, one can stay at v0.23.1 of
coffee-compile or write a plugin for coffee-compile.

## v0.23.1 (2016-11-06)
- Fix weird editor behavior by setting autoHeight to false (default value) (#47)

## v0.23.0 (2016-10=31)
- Use package-local versions of CoffeeScript and coffee-react-transform, if available (#46)
- Fix deprecated text editor setting

## v0.22.0 (2016-08-11)
- Bump minimum Atom requirement to v1.9.0
- Fix for saving preview pane as a file (#44)

## v0.21.1 (2016-01-19)
- Disable prompt to save when closing preview pane (#42)

## v0.21.0 (2015-12-23)
- Remove `enableProjectConfig` option
- Switch to check for the existence of coffee-compile.cson
- Update coffee-script to 1.10.0
- Update compileOnSave and compileOnSaveWithoutPreview descriptions

## v0.20.1 (2015-11-19)
- Fix recompiling not updating preview pane
- Update preview panel when saving original editor

## v0.20.0 (2015-11-18)
- Fix Coffee-Compile failed to create preview text editor

## v0.19.2 (2015-10-16)
- Fix `auto compile` saving and compiling non-coffee files

## v0.19.1 (2015-10-08)
- Add source.coffee.jsx to list of selectors

## v0.19.0 (2015-10-05)
- Add `Split pane direction` option
  - Can now choose the direction where to show the preview pane

## v0.18.1 (2015-09-24)
- Fix project config
  - Fix project config not set on initial load
  - Fix project config not clearing properly when removing file
  - Fix project config not getting correct value when one of the config changes
- Better source config handling

## v0.18.0 (2015-08-05)
- Add project based configurations

## v0.17.3 (2015-07-28)
- Make sure all variables are string before joining

## v0.17.2 (2015-07-27)
- Fix src check breaking when not opened in project

## v0.17.1 (2015-07-27)
- Fix empty preview pane when `compileOnSaveWithoutPreview` is on

## v0.17.0 (2015-07-26)
- Add `cwd` and `source` option for writing to files
  - `cwd` sets the root folder to compile (relative to project root)
  - `source(s)` are folders to compile (relative to cwd)
- Show error notifications when failed to compile to file

## v0.16.1 (2015-06-13)
- Suppress exception when saving on preview pane

## v0.16.0 (2015-05-25)
- Made `Compile on save without preview` option work with autosave

## v0.15.0 (2015-05-13)
- Fixed subsequent compilations not updating same tab

## v0.14.0 (2015-05-06)
- Added destination filepath option
- Added flatten option
- Fixed toggling `compiled on save` does not work without reloading Atom

## v0.13.0 (2015-04-17)
- Updated coffee-script to 1.9.2

## v0.12.0 (2015-04-09)
- Added `Compile CJSX` option (disabled by default)

## v0.11.0 (2015-04-09)
- Fixed compiled not searchable.
- Added coffee-compile to menu

## v0.10.0 (2015-01-29)
- Updated coffee-script to 1.9.0

## v0.9.1 (2015-01-26)
- Fixed `No top level function wrapper` not working

## v0.9.0 (2015-01-24)
- Updated to using Atom 1.0 API

## v0.8.4 (2014-10-27)
- Reenabled focusing on editor
- Cleaned up package

## v0.8.3 (2014-10-22)
- Fixed preview not working due to API changes

## v0.8.2 (2014-09-16)
- Added check to make sure user is compiling and saving Coffeescript

## v0.8.1 (2014-09-16)
- Fixed not able to compile and save when opening a preview pane

## v0.8.0 (2014-09-16)
- Added `compile on save without preview` feature (disabled by default)

## v0.7.0 (2014-09-14)
- Fixed compile on save and updated calback API

## v0.6.0 (2014-08-29)
- Updated CoffeeCompile to support Atom's new ReactEditor

## v0.5.0 (2014-08-17)
- Converted compiled view to editor which brings line numbers and code selection

## v0.4.0 (2014-06-22)
- Added keybinding for Linux and Windows

## v0.3.2 (2014-04-24)
- Fixed horizontal scrolling

## v0.3.1 (2014-04-08)
- Added `focus editor after compile` option (disabled by default)

## v0.3.0 (2014-03-25)
- Added `compile on save` feature (disabled by default)

## v0.2.1 (2014-03-11)
- Compiled view style now matches editor style

## v0.2.0 (2014-03-10)
- Litcoffee support, Top-level wrapper function option, Grammar config option

## v0.1.4 (2014-03-09)
- Fixed spliting pane in certain pane arrangement breaks Atom

## v0.1.3 (2014-03-07)
- Fixed view breaking with jshint

## v0.1.2 (2014-03-01)
- Code cleanup

## v0.1.1 (2014-03-01)
- Fixed README screenshot

## v0.1.0 (2014-03-01)
- Initial Release
