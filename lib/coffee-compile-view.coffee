{TextEditorView} = require 'atom'
coffee = require 'coffee-script'
path = require 'path'
fs = require 'fs'

module.exports =
class CoffeeCompileView extends TextEditorView
  constructor: ({@sourceEditorId, @sourceEditor}) ->
    @view = super

    # HACK: Since the html is getting passed back instead of the instance,
    # the return object doesn't have getTitle function
    @view.getTitle = @getTitle.bind(this)

    # Used for unsubscribing callbacks on editor text buffer
    @disposables = []

    if @sourceEditorId? and not @sourceEditor
      @sourceEditor = @getSourceEditor @sourceEditorId

    if @sourceEditor?
      @bindCoffeeCompileEvents()

    # set editor grammar to Javascript
    @view.getModel().setGrammar atom.syntax.selectGrammar("hello.js")

    @renderCompiled()

    if atom.config.get('coffee-compile.compileOnSave') or
        atom.config.get('coffee-compile.compileOnSaveWithoutPreview')
      CoffeeCompileView.saveCompiled @sourceEditor

    # TODO: Disable for now. Re-enable this in next release
    # if atom.config.get('coffee-compile.focusEditorAfterCompile')
    #   activePane.activate()

    return @view

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
    code = @getSelectedCode()

    try
      text = CoffeeCompileView.compile @sourceEditor, code
    catch e
      text = e.stack

    @view.getModel().setText text

  getTitle: ->
    if @sourceEditor?
      "Compiled #{@sourceEditor.getTitle()}"
    else
      "Compiled Javascript"

  getUri: -> "coffeecompile://editor/#{@sourceEditorId}"

  @compile: (editor, code) ->
    grammarScopeName = editor.getGrammar().scopeName

    bare     = atom.config.get('coffee-compile.noTopLevelFunctionWrapper') or true
    literate = grammarScopeName is "source.litcoffee"

    return coffee.compile code, {bare, literate}

  @saveCompiled: (editor, callback) ->
    try
      text     = CoffeeCompileView.compile editor, editor.getText()
      srcPath  = editor.getPath()
      srcExt   = path.extname srcPath
      destPath = path.join(
        path.dirname(srcPath), "#{path.basename(srcPath, srcExt)}.js"
      )
      fs.writeFile destPath, text, callback

    catch e
      console.error "Coffee-compile: #{e.stack}"
