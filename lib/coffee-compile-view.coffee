{TextEditorView} = require 'atom'
util = require './util'

module.exports =
class CoffeeCompileView extends TextEditorView
  constructor: ({@sourceEditorId, @sourceEditor}) ->
    @view = super

    # Used for unsubscribing callbacks on editor text buffer
    @disposables = []

    if @sourceEditorId? and not @sourceEditor
      @sourceEditor = util.getTextEditorById @sourceEditorId

    if @sourceEditor?
      @bindCoffeeCompileEvents()

    @bindMethods()

    # set editor grammar to Javascript
    @view.getModel().setGrammar atom.syntax.selectGrammar("hello.js")

    @renderCompiled()

    if atom.config.get('coffee-compile.compileOnSave') or
        atom.config.get('coffee-compile.compileOnSaveWithoutPreview')
      util.compileToFile @sourceEditor

    return @view

  bindMethods: ->
    # HACK: Since the html is getting passed back instead of the instance,
    # the return object doesn't have getTitle function
    @view.getTitle = @getTitle.bind this

    @view.beforeRemove = @destroy.bind this

    @view.getUri = @getUri.bind this

  bindCoffeeCompileEvents: ->
    if atom.config.get('coffee-compile.compileOnSave') and not
        atom.config.get('coffee-compile.compileOnSaveWithoutPreview')
      buffer = @sourceEditor.getBuffer()

      @disposables.push buffer.onDidSave =>
        @renderCompiled()
        util.compileToFile @sourceEditor

      @disposables.push buffer.onDidReload =>
        @renderCompiled()
        util.compileToFile @sourceEditor

  destroy: ->
    disposable.dispose() for disposable in @disposables

  renderCompiled: ->
    code = util.getSelectedCode @sourceEditor

    try
      literate = util.isLiterate @sourceEditor
      text     = util.compile code, literate
    catch e
      text = e.stack

    @view.getModel().setText text

  getTitle: ->
    if @sourceEditor?
      "Compiled #{@sourceEditor.getTitle()}"
    else
      "Compiled Javascript"

  getUri: -> "coffeecompile://editor/#{@sourceEditorId}"
