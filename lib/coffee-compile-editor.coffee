{TextEditor} = require 'atom'
util = require './util'

module.exports =
class CoffeeCompileEditor extends TextEditor
  constructor: ({@sourceEditor}) ->
    super

    # Used for unsubscribing callbacks on editor text buffer
    @disposables = []
    
    @bindCoffeeCompileEvents() if @sourceEditor?

    # set editor grammar to Javascript
    @setGrammar atom.grammars.selectGrammar("hello.js")

    @renderCompiled()

    if atom.config.get('coffee-compile.compileOnSave') or
        atom.config.get('coffee-compile.compileOnSaveWithoutPreview')
      util.compileToFile @sourceEditor

  bindCoffeeCompileEvents: ->
    if atom.config.get('coffee-compile.compileOnSave') and not
        atom.config.get('coffee-compile.compileOnSaveWithoutPreview')

      @disposables.push @sourceEditor.getBuffer().onDidSave => @renderAndSave()
      @disposables.push @sourceEditor.getBuffer().onDidReload => @renderAndSave()

  destroyed: ->
    disposable.dispose() for disposable in @disposables

    super

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
