{EditorView} = require 'atom'
coffee = require 'coffee-script'
path = require 'path'
fs = require 'fs'

module.exports =
class CoffeeCompileView extends EditorView
  constructor: ({@sourceEditorId, @sourceEditor}) ->
    super

    if @sourceEditorId? and not @sourceEditor
      @sourceEditor = @getSourceEditor @sourceEditorId

    if @sourceEditor?
      @bindCoffeeCompileEvents()

    # set editor grammar to Javascript
    @editor.setGrammar atom.syntax.selectGrammar("hello.js")

  bindCoffeeCompileEvents: ->
    if atom.config.get('coffee-compile.compileOnSave')
      @subscribe @sourceEditor.buffer, 'saved', => @saveCompiled()

  getSourceEditor: (id) ->
    for editor in atom.workspace.getEditors()
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

  compile: (code) ->
    grammarScopeName = @sourceEditor.getGrammar().scopeName

    bare     = atom.config.get('coffee-compile.noTopLevelFunctionWrapper') or true
    literate = grammarScopeName is "source.litcoffee"

    return coffee.compile code, {bare, literate}

  saveCompiled: (callback) ->
    try
      text     = @compile @sourceEditor.getText()
      srcPath  = @sourceEditor.getPath()
      srcExt   = path.extname srcPath
      destPath = path.join(
        path.dirname(srcPath), "#{path.basename(srcPath, srcExt)}.js"
      )
      fs.writeFile destPath, text, callback

    catch e
      console.error "Coffee-compile: #{e.stack}"

  renderCompiled: ->
    code = @getSelectedCode()

    try
      text = @compile code
    catch e
      text = e.stack

    @getEditor().setText text

  getTitle: ->
    if @sourceEditor?
      "Compiled #{@sourceEditor.getTitle()}"
    else
      "Compiled Javascript"

  getUri: -> "coffeecompile://editor/#{@sourceEditorId}"
