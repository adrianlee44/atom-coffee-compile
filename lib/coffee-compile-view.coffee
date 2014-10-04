{EditorView} = require "atom"
coffee = require "coffee-script"
fs = require "fs"
helper = require "./helper"
mkdirp = require "mkdirp"

module.exports =
class CoffeeCompileView extends EditorView
  constructor: ({@sourceEditorId, @sourceEditor}) ->
    super

    # Used for unsubscribing callbacks on editor text buffer
    @disposables = []

    if @sourceEditorId? and not @sourceEditor
      @sourceEditor = @getSourceEditor @sourceEditorId

    if @sourceEditor?
      @bindCoffeeCompileEvents()

    # set editor grammar to Javascript
    @editor.setGrammar atom.syntax.selectGrammar("hello.js")

  bindCoffeeCompileEvents: ->
    if atom.config.get('coffee-compile.compileOnSave') and not
        atom.config.get('coffee-compile.compileOnSaveWithoutPreview')
      buffer = @sourceEditor.getBuffer()

      @disposables.push buffer.onDidSave =>
        @renderCompiled()
        CoffeeCompileView.saveCompiled @sourceEditor

      @disposables.push buffer.onDidReload =>
        @renderCompiled()
        CoffeeCompileView.saveCompiled @sourceEditor

  destroy: ->
    disposable.dispose() for disposable in @disposables

  getSourceEditor: (id) ->
    for editor in atom.workspace.getTextEditors()
      return editor if editor.id?.toString() is id.toString()

    return null

  getSelectedCode: ->
    range = @sourceEditor.getSelectedBufferRange()
    code  =
      if range.isEmpty()
        @sourceEditor.getText()
      else
        @sourceEditor.getTextInBufferRange(range)

    return code

  renderCompiled: ->
    code    = @getSelectedCode()
    options = helper.compileOptions @sourceEditor

    try
      text = coffee.compile code, options

      if options.sourceMap and text.js
        text = text.js

    catch e
      text = e.stack

    @getEditor().setText text

  getTitle: ->
    if @sourceEditor?
      "Compiled #{@sourceEditor.getTitle()}"
    else
      "Compiled Javascript"

  getUri: -> "coffeecompile://editor/#{@sourceEditorId}"

  @saveCompiled: (editor, callback) ->
    options = helper.compileOptions editor

    try
      text = coffee.compile editor.getText(), options

      if options.sourceMap

        v3SourceMap = text.v3SourceMap

        mkdirp options.sourceMapDir, {}, (err) ->
          if err
            console.error err
            return

          fs.writeFile options.sourceMapPath, v3SourceMap

        text = text.js

      mkdirp options.generatedDir, {}, (err) ->
        if err
          console.error err
          return

        fs.writeFile options.generatedPath, text, callback

    catch e
      console.error "Coffee-compile: #{e.stack}"
