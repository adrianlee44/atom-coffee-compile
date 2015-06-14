{TextEditor} = require 'atom'
util = require './util'
pluginManager = require './plugin-manager'

module.exports =
class CoffeeCompileEditor extends TextEditor
  constructor: ({@sourceEditor}) ->
    super

    if atom.config.get('coffee-compile.compileOnSave') and not
        atom.config.get('coffee-compile.compileOnSaveWithoutPreview')
      @disposables.add @sourceEditor.getBuffer().onDidSave => @renderAndSave()
      @disposables.add @sourceEditor.getBuffer().onDidReload => @renderAndSave()

    # set editor grammar to correct language
    grammar = atom.grammars.selectGrammar pluginManager.getCompiledScopeByEditor(@sourceEditor)
    @setGrammar grammar

    if atom.config.get('coffee-compile.compileOnSave') or
        atom.config.get('coffee-compile.compileOnSaveWithoutPreview')
      util.compileToFile @sourceEditor

    # HACK: Override TextBuffer saveAs function
    @buffer.saveAs = ->

  renderAndSave: ->
    @renderCompiled()
    util.compileToFile @sourceEditor

  renderCompiled: ->
    code = util.getSelectedCode @sourceEditor

    try
      text = util.compile code, @sourceEditor
    catch e
      text = e.stack

    @setText text

  getTitle: -> "Compiled #{@sourceEditor?.getTitle() or ''}".trim()
  getURI:   -> "coffeecompile://editor/#{@sourceEditor.id}"
