{TextEditorView} = require 'atom-space-pen-views'
util = require './util'

module.exports =
class CoffeeCompileView extends TextEditorView
  constructor: ({@sourceEditorId, @sourceEditor}) ->
    super

    # Used for unsubscribing callbacks on editor text buffer
    @disposables = []

    if @sourceEditorId? and not @sourceEditor
      @sourceEditor = util.getTextEditorById @sourceEditorId

    if @sourceEditor?
      @bindCoffeeCompileEvents()

    # set editor grammar to Javascript
    this.getModel().setGrammar atom.grammars.selectGrammar("hello.js")

    @renderCompiled()

    if atom.config.get('coffee-compile.compileOnSave') or
        atom.config.get('coffee-compile.compileOnSaveWithoutPreview')
      util.compileToFile @sourceEditor

  bindCoffeeCompileEvents: ->
    if atom.config.get('coffee-compile.compileOnSave') and not
        atom.config.get('coffee-compile.compileOnSaveWithoutPreview')

      @disposables.push @sourceEditor.getBuffer().onDidSave => @renderAndSave()
      @disposables.push @sourceEditor.getBuffer().onDidReload => @renderAndSave()

  destroy: ->
    disposable.dispose() for disposable in @disposables

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

    this.getModel().setText text

  getTitle: ->
    if @sourceEditor?
      "Compiled #{@sourceEditor.getTitle()}"
    else
      "Compiled Javascript"

  getURI: -> "coffeecompile://editor/#{@sourceEditorId}"
