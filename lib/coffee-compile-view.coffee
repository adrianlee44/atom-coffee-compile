{$, $$$, EditorView, ScrollView} = require 'atom'
coffee = require 'coffee-script'
_ = require 'underscore-plus'
path = require 'path'
fs = require 'fs'

module.exports =
class CoffeeCompileView extends ScrollView
  @content: ->
    @div class: 'coffee-compile native-key-bindings', tabindex: -1, =>
      @div class: 'editor editor-colors', =>
        @div outlet: 'compiledCode', class: 'lang-javascript lines'

  constructor: (@editorId) ->
    super

    @editor = @getEditor @editorId
    if @editor?
      @trigger 'title-changed'
      @bindEvents()
    else
      @parents('.pane').view()?.destroyItem(this)

  destroy: ->
    @unsubscribe()

  bindEvents: ->
    @subscribe atom.syntax, 'grammar-updated', _.debounce((=> @renderCompiled()), 250)
    @subscribe this, 'core:move-up', => @scrollUp()
    @subscribe this, 'core:move-down', => @scrollDown()

    if atom.config.get('coffee-compile.compileOnSave')
      @subscribe @editor.buffer, 'saved', => @saveCompiled()

  getEditor: (id) ->
    for editor in atom.workspace.getEditors()
      return editor if editor.id?.toString() is id.toString()
    return null

  getSelectedCode: ->
    range = @editor.getSelectedBufferRange()
    code  =
      if range.isEmpty()
        @editor.getText()
      else
        @editor.getTextInBufferRange(range)

    return code

  compile: (code) ->
    grammarScopeName = @editor.getGrammar().scopeName

    bare     = atom.config.get('coffee-compile.noTopLevelFunctionWrapper') or true
    literate = grammarScopeName is "source.litcoffee"

    return coffee.compile code, {bare, literate}

  saveCompiled: (callback) ->
    try
      text     = @compile @editor.getText()
      srcPath  = @editor.getPath()
      srcExt   = path.extname srcPath
      destPath = path.join(
        path.dirname(srcPath), "#{path.basename(srcPath, srcExt)}.js"
      )
      fs.writeFileSync destPath, text

    catch e
      console.error "Coffee-compile: #{e.stack}"

    callback?()

  renderCompiled: (callback) ->
    code = @getSelectedCode()

    try
      text = @compile code
    catch e
      text = e.stack

    grammar = atom.syntax.selectGrammar("hello.js", text)
    @compiledCode.empty()

    for tokens in grammar.tokenizeLines(text)
      attributes = class: "line"
      @compiledCode.append(EditorView.buildLineHtml({tokens, text, attributes}))

    # Match editor styles
    @compiledCode.css
      fontSize: atom.config.get('editor.fontSize') or 12
      fontFamily: atom.config.get('editor.fontFamily')

    callback?()

  getTitle: ->
    if @editor.getPath()
      "Compiled #{path.basename(@editor.getPath())}"
    else if @editor
      "Compiled #{@editor.getTitle()}"
    else
      "Compiled Javascript"

  getUri:   -> "coffeecompile://editor/#{@editorId}"
  getPath:  -> @editor.getPath()
