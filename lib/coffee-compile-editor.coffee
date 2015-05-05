{TextEditor} = require 'atom'
util = require './util'

module.exports =
class CoffeeCompileEditor extends TextEditor
  constructor: ({@sourceEditor}) ->
    super

    if atom.config.get('coffee-compile.compileOnSave') and not
        atom.config.get('coffee-compile.compileOnSaveWithoutPreview')

      @disposables.add @sourceEditor.getBuffer().onDidSave => @renderAndSave()
      @disposables.add @sourceEditor.getBuffer().onDidReload => @renderAndSave()

    # set editor grammar to Javascript
    @setGrammar atom.grammars.selectGrammar("hello.js")

    @renderCompiled()

    if atom.config.get('coffee-compile.compileOnSave') or
        atom.config.get('coffee-compile.compileOnSaveWithoutPreview')
      util.compileToFile @sourceEditor

  renderAndSave: ->
    @renderCompiled()
    util.compileToFile @sourceEditor

  renderCompiled: ->
    code = util.getSelectedCode @sourceEditor

    try
      literate = util.isLiterate @sourceEditor
      text     = util.compile code, literate
    catch e
      text = e.stack

    @setText text

  getTitle: ->
    if @sourceEditor?
      "Compiled #{@sourceEditor.getTitle()}"
    else
      "Compiled Javascript"

  getURI: -> "coffeecompile://editor/#{@sourceEditorId}"
